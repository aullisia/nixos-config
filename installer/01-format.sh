#!/usr/bin/env bash
# Stage 1 — destructive filesystem setup.
#
# The user creates partitions in GParted. This stage:
#   - interactively selects the EFI, NixOS (btrfs) and optionally a dedicated
#     swap partition
#   - FORMATS ONLY those selected partitions
#   - creates the Btrfs subvolumes: @ @nix @persistent @blank (/home is just
#     a directory inside @, not its own subvolume — see
#     modules/system/impermanence.nix)
#     (@blank is a pristine empty snapshot of @, used to roll it back to a
#     clean state on every boot)
#   - mounts everything under /mnt (impermanence-ready layout)
#   - enables the dedicated swap partition if one was selected
#   - persists the selected devices in installer state (later stages use it)
#
# It does NOT copy the flake, does NOT generate a hardware configuration and
# does NOT touch any other disk or partition.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

require_root
require_live_iso
require_cmd lsblk mount umount mountpoint findmnt blkid mkfs.btrfs btrfs mkswap swapon stat

# mkfs.fat and mkfs.vfat are interchangeable; the ISO ships one of them.
if ! command -v mkfs.fat >/dev/null 2>&1 && ! command -v mkfs.vfat >/dev/null 2>&1; then
    die "neither mkfs.fat nor mkfs.vfat is available (install dosfstools)."
fi

state_load

EFI_PART="${EFI_PART:-}"
ROOT_PART="${ROOT_PART:-}"
SWAP_PART="${SWAP_PART:-}"

section "STAGE 1 OF 4 — FORMAT, BTRFS SUBVOLUMES & MOUNTS"

echo
echo "The partition layout is created by YOU in GParted, so dual-booting,"
echo "shared data disks, etc. stay fully under your control. This stage only"
echo "needs three answers:"
echo
echo "  1) EFI system partition   (small FAT32, ~512MiB+, 'EFI System' type)"
echo "  2) NixOS system partition (btrfs, the rest of your disk)"
echo "  3) swap partition         (optional — the flake also uses zram + swapfile)"
echo
echo "WARNING: everything on the partitions you select will be DESTROYED."
echo "No other disk or partition is ever touched."
echo

read -rp "Have you finished partitioning with GParted? Press Enter to list disks..."

print_disks

# ------------------------------------------------------------
# EFI partition
# ------------------------------------------------------------

if [[ -z "$EFI_PART" ]]; then
    suggested="$(find_efi_partitions | head -n1 || true)"
    while :; do
        read -rp "EFI system partition${suggested:+  [${suggested}]}: " answer
        EFI_PART="${answer:-$suggested}"
        [[ -n "$EFI_PART" ]] || echo "  EFI partition is required."
        is_block_device "$EFI_PART" || { echo "  $EFI_PART is not a block device."; EFI_PART=""; continue; }
        is_partition "$EFI_PART" || { echo "  $EFI_PART is not a partition (use a partition, not the whole disk)."; EFI_PART=""; continue; }
        break
    done
fi

# ------------------------------------------------------------
# NixOS root partition
# ------------------------------------------------------------

if [[ -z "$ROOT_PART" ]]; then
    suggested="$(suggest_root_partition || true)"
    while :; do
        read -rp "NixOS btrfs partition${suggested:+  [${suggested}]}: " answer
        ROOT_PART="${answer:-$suggested}"
        [[ -n "$ROOT_PART" ]] || { echo "  NixOS partition is required."; continue; }
        is_block_device "$ROOT_PART" || { echo "  $ROOT_PART is not a block device."; ROOT_PART=""; continue; }
        is_partition "$ROOT_PART" || { echo "  $ROOT_PART is not a partition."; ROOT_PART=""; continue; }
        break
    done
fi

# ------------------------------------------------------------
# Optional dedicated swap partition
# ------------------------------------------------------------

if [[ -z "$SWAP_PART" ]]; then
    suggested="$(suggest_swap_partition || true)"
    read -rp "Swap partition (leave empty for none)${suggested:+  [${suggested}]}: " answer
    if [[ -n "$answer" ]]; then
        SWAP_PART="$answer"
    elif [[ -n "$suggested" ]]; then
        echo "  Found an existing swap partition: $suggested"
        if yesno "  Use it?"; then
            SWAP_PART="$suggested"
        fi
    fi
    if [[ -n "$SWAP_PART" ]]; then
        is_block_device "$SWAP_PART" || die "$SWAP_PART is not a block device."
        is_partition "$SWAP_PART" || die "$SWAP_PART is not a partition."
    fi
fi

# ------------------------------------------------------------
# Safety checks
# ------------------------------------------------------------

[[ "$ROOT_PART" != "$EFI_PART" ]] || die "EFI and NixOS partitions must be different."
if [[ -n "$SWAP_PART" ]]; then
    [[ "$SWAP_PART" != "$EFI_PART" ]] || die "swap and EFI partition must be different."
    [[ "$SWAP_PART" != "$ROOT_PART" ]] || die "swap and NixOS partition must be different."
fi

# Refuse to run if any selected partition is currently mounted under /mnt.
for p in "$EFI_PART" "$ROOT_PART"; do
    if findmnt -n -o TARGET "$p" 2>/dev/null | grep -q "^/mnt"; then
        die "$p is currently mounted under /mnt — unmount it first (umount -R /mnt)."
    fi
done

section "FINAL WIPE PLAN"
echo "THE FOLLOWING PARTITIONS WILL BE FORMATTED:"
echo
echo "  EFI:     $EFI_PART   -> FAT32"
echo "  NixOS:   $ROOT_PART  -> Btrfs"
if [[ -n "$SWAP_PART" ]]; then
    echo "  Swap:    $SWAP_PART  -> swap"
fi
echo
echo "ALL DATA ON THESE PARTITIONS WILL BE LOST."
echo
cat <<'EOF'
Layout after installation:

  FAT32 (EFI)
  └── /boot

  Btrfs
  ├── @            → /            (wiped back to @blank on every boot —
  │                                 /home lives inside here too, not
  │                                 separately mounted; flake + user data
  │                                 survive via the /persistent bind mounts)
  ├── @nix         → /nix
  ├── @persistent  → /persistent  (persistent; bind-mounted back into /
  │                                 by the impermanence module)
  └── @blank       (not mounted — pristine empty snapshot, template for @)
EOF
echo
confirm_wipe

# ------------------------------------------------------------
# Unmount everything involved, best-effort
# ------------------------------------------------------------

echo
info "Releasing previous mounts..."
umount -R "$TARGET" 2>/dev/null || true
umount "$EFI_PART" 2>/dev/null || true
umount "$ROOT_PART" 2>/dev/null || true
[[ -n "$SWAP_PART" ]] && swapoff "$SWAP_PART" 2>/dev/null || true

# ------------------------------------------------------------
# Format
# ------------------------------------------------------------

echo
section "FORMATTING"

info "Formatting EFI partition as FAT32..."
if command -v mkfs.fat >/dev/null 2>&1; then
    mkfs.fat -F 32 -n BOOT "$EFI_PART"
else
    mkfs.vfat -F 32 -n BOOT "$EFI_PART"
fi

info "Formatting NixOS partition as Btrfs..."
mkfs.btrfs -f -L nixos "$ROOT_PART"

if [[ -n "$SWAP_PART" ]]; then
    info "Formatting swap partition..."
    mkswap -L swap "$SWAP_PART"
fi

# ------------------------------------------------------------
# Btrfs subvolumes
# ------------------------------------------------------------

section "BTRFS SUBVOLUMES"

mkdir -p "$BTRFS_TOP"
mount -t btrfs -o subvolid=5 "$ROOT_PART" "$BTRFS_TOP"

for subvolume in "${REQUIRED_SUBVOLS[@]}"; do
    if btrfs_subvolume_exists "$subvolume"; then
        echo "  subvolume already exists: $subvolume"
        continue
    fi
    case "$subvolume" in
        @blank)
            # Must be an actual snapshot of @ (not an independent empty
            # subvolume) so the impermanence rollback semantics are exact,
            # even though at this point in a fresh install @ happens to be
            # empty too.
            require_subvolume "@"
            echo "  snapshotting subvolume:   @blank (from @)"
            btrfs subvolume snapshot "$BTRFS_TOP/@" "$BTRFS_TOP/$subvolume"
            ;;
        *)
            echo "  creating subvolume:       $subvolume"
            btrfs subvolume create "$BTRFS_TOP/$subvolume"
            ;;
    esac
done

echo
info "Current subvolumes:"
btrfs subvolume list "$BTRFS_TOP"

# ------------------------------------------------------------
# Mount target tree
# ------------------------------------------------------------

section "MOUNTING /mnt"

mkdir -p "$TARGET"

# Mount the root subvolume FIRST — it replaces whatever was at $TARGET (an
# empty tmpfs directory on the ISO) with the (currently empty) @ subvolume.
# Only after this can subdirectories be created *inside* it for the other
# subvolumes/EFI to mount onto; creating them beforehand would just leave
# them stranded under the old, now-unreachable tmpfs directory.
mount -t btrfs -o subvol=@ "$ROOT_PART" "$TARGET"

# /home is deliberately NOT a separate subvolume/mount — it's just an
# ordinary directory inside @ now, wiped along with everything else under /
# on every boot. See modules/system/impermanence.nix for why.
mkdir -p \
    "$TARGET/nix" \
    "$TARGET/home" \
    "$TARGET/persistent" \
    "$TARGET/boot"

mount -t btrfs -o subvol=@nix "$ROOT_PART" "$TARGET/nix"
mount -t btrfs -o subvol=@persistent "$ROOT_PART" "$TARGET/persistent"
mount "$EFI_PART" "$TARGET/boot"

# Release the temporary top-level mount.
umount "$BTRFS_TOP"

if [[ -n "$SWAP_PART" ]]; then
    swapon "$SWAP_PART"
    echo "  swap enabled: $SWAP_PART"
fi

# ------------------------------------------------------------
# Verify
# ------------------------------------------------------------

section "MOUNT VERIFICATION"

findmnt -R "$TARGET"

echo
info "Persisting selections for later stages..."
state_save TARGET HOST EFI_PART ROOT_PART SWAP_PART

echo
section "STAGE 1 COMPLETE"
echo "The filesystem layout is ready under /mnt."
echo
echo "Run the next stage:"
echo "  sudo $SCRIPT_DIR/02-configure.sh"