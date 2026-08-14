#!/usr/bin/env bash
# Stage 2 — non-destructive configuration generation.
#
# This stage:
#   - verifies the /mnt mount layout and required Btrfs subvolumes
#   - verifies the source repository ($REPO_DIR, under /home/...) is a real flake
#   - copies the source flake into the target ($TARGET_FLAKE =
#     /mnt/persistent/home/<user>/new-nix-config), dropping VCS metadata and
#     the installer — this is the persistent backing path;
#     environment.persistence."/persistent".users.<user> bind-mounts it to
#     ~/new-nix-config after each boot's root wipe
#   - generates a REAL hardware-configuration.nix from the mounted target with
#     'nixos-generate-config --root /mnt --show-hardware-config' — no hardcoded
#     CPU/PCI/GPU/firmware/UUID values
#   - writes it into both the target copy (what nixos-install consumes) and the
#     source repository (so the user's working tree stays coherent)
#   - seeds /persistent for a FUTURE Impermanence setup
#
# It does NOT format anything, does NOT create /mnt/etc/nixos/configuration.nix,
# does NOT create installer-filesystems.nix, and does NOT install NixOS.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

require_root
require_live_iso
require_cmd mkdir cp rm nixos-generate-config ssh-keygen stat findmnt mount umount mountpoint btrfs

state_load

HOST="${HOST:-}"
SWAP_PART="${SWAP_PART:-}"

# ------------------------------------------------------------
# Pick the host
# ------------------------------------------------------------

HOST_DEFAULT="$(list_hosts | head -n1)"
[[ -n "$HOST_DEFAULT" ]] || HOST_DEFAULT="test"

if [[ -z "$HOST" ]]; then
    echo
    echo "Available hosts in this flake:"
    list_hosts | sed 's/^/  /'
    echo
    HOST="$(prompt_default "Host to configure" "$HOST_DEFAULT")"
fi
[[ -n "$HOST" ]] || die "no host name given."
valid_hostname "$HOST" || die "host '$HOST' is not a valid Nix identifier (use letters/numbers/underscore)."

set_target_flake "$HOST"
assert_source_is_not_target
require_source_flake

section "STAGE 2 — HARDWARE & FLAKE CONFIGURATION"

# ------------------------------------------------------------
# Mount layout check
# ------------------------------------------------------------

require_mounts \
    "$TARGET" \
    "$TARGET/nix" \
    "$TARGET/persistent" \
    "$TARGET/boot"

trap release_btrfs_top EXIT
for subvol in "${REQUIRED_SUBVOLS[@]}"; do
    require_subvolume "$subvol"
done
release_btrfs_top
trap - EXIT

echo "  required subvolumes exist: ${REQUIRED_SUBVOLS[*]}"

# ------------------------------------------------------------
# Host policy (only for hosts with no policy in the flake)
# ------------------------------------------------------------
#
# This creates a *policy* skeleton only: includes for the standard aspects and
# an import of the (about to be generated) hardware-configuration.nix.  It
# deliberately sets NO kernel, NO hardware values, NO GPU/firmware options —
# those are host-policy and machine decisions, not installer decisions.

create_host_policy() {
    local host="$1"
    local policy="$REPO_DIR/modules/hosts/$host/default.nix"

    mkdir -p "$REPO_DIR/modules/hosts/$host"

    cat > "$policy" <<EOF
{ den, inputs, ... }:
{
  den.aspects.$host = {
    includes = [
      # Core system
      den.aspects.boot
      den.aspects.locale
      den.aspects.networking
      den.aspects.systemd
      den.aspects.users
      den.aspects.overlays
      den.aspects.nixsettings

      # Hardware
      den.aspects.kernel

      # Services
      den.aspects.ssh
      den.aspects.swap
      den.aspects.impermanence
    ];

    nixos =
      {
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ (inputs.self + "/hosts/$host/hardware-configuration.nix") ];

        # Host policy skeleton.  Machine specifics (CPU vendor, kernel, storage,
        # GPU, firmware, UUIDs) are intentionally absent: the installer writes
        # the real hardware-configuration.nix from the actual machine, and
        # kernel / GPU choices are a host-policy decision.
      };
  };
}
EOF

    # Register the host in modules/hosts.nix (reuses the shared user/timezone).
    if ! host_is_in_flake "$REPO_DIR" "$host"; then
        local tmp
        tmp="$(mktemp)"
        awk -v h="$host" '
            /^[[:space:]]*den\.hosts\.x86_64-linux = \{/ && !done {
                print
                print "    " h " = {"
                print "      users.aul = aul;"
                print "      ## Freeform attributes"
                print "      timezone = timezone;"
                print "    };"
                done = 1
                next
            }
            { print }
        ' "$REPO_DIR/modules/hosts.nix" > "$tmp"
        mv "$tmp" "$REPO_DIR/modules/hosts.nix"
        echo "  registered host '$host' in modules/hosts.nix"
    fi

    echo
    info "Created host policy skeleton:"
    echo "  $policy"
}

if ! host_policy_exists "$HOST"; then
    echo
    warn "Host '$HOST' has no policy in this flake."
    if yesno "Create a host policy skeleton for it?"; then
        create_host_policy "$HOST"
    else
        echo "Existing hosts:"
        list_hosts | sed 's/^/  /'
        die "choose an existing host."
    fi
fi

host_is_in_flake "$REPO_DIR" "$HOST" \
    || warn "host '$HOST' has a policy file but is not registered in modules/hosts.nix — evaluation/installation will fail until it is."

# ------------------------------------------------------------
# Copy source flake into the target checkout
# ------------------------------------------------------------
#
# The source stays under /home/.../new-nix-config.  The target checkout is the
# copy nixos-install consumes. .git is dropped (large, not useful on the
# target); the installer folder is deliberately KEPT this time — it'll live
# in the same git repo going forward, and it's genuinely useful to have on
# the installed system (e.g. installer/test-impermanence.sh). Since these
# scripts are destructive if run against a live system by mistake, they
# each check require_live_iso() (see lib.sh) and refuse to run unless
# actually booted from the install media — safe to leave them lying around.

echo
info "Copying source flake into $TARGET_FLAKE (user: $TARGET_USER)..."
rm -rf "$TARGET_FLAKE"
mkdir -p "$TARGET/persistent/home/$TARGET_USER" "$TARGET_FLAKE"

cp -a "$REPO_DIR/." "$TARGET_FLAKE/"

rm -rf "$TARGET_FLAKE/.git"

# UID/GID for $TARGET_USER don't exist yet (nixos-install hasn't run), so the
# copy is root-owned for now. Stage 4 chowns it to the real user right after
# the system is installed.

# ------------------------------------------------------------
# Generate the real hardware configuration
# ------------------------------------------------------------

echo
info "Detecting hardware with nixos-generate-config (scans the mounts under $TARGET)..."

HW_TMP="$(mktemp)"
trap 'rm -f "$HW_TMP"' EXIT

nixos-generate-config --root "$TARGET" --show-hardware-config > "$HW_TMP"

# The generated file must declare the root and every subvolume mount plus the
# EFI mount.  fsType btrfs confirms the root is not e.g. ext4 (a leftover from
# a wrong partition choice would be caught here).
grep -Fq 'fileSystems."/"' "$HW_TMP" || die "hardware detection failed (no / filesystem)."
grep -Fq 'fsType = "btrfs"' "$HW_TMP" || die "hardware detection failed (root is not btrfs)."
grep -Fq 'fileSystems."/boot"' "$HW_TMP" || die "hardware detection missed the /boot filesystem."
for subvol in "${MOUNTED_SUBVOLS[@]}"; do
    grep -Fq "subvol=$subvol" "$HW_TMP" || die "hardware detection missed subvolume $subvol."
done

# If a dedicated swap partition is selected, the generated config must reflect it.
if [[ -n "$SWAP_PART" ]]; then
    swaptype="$(blkid -s TYPE -o value "$SWAP_PART" 2>/dev/null || true)"
    [[ "$swaptype" == "swap" ]] \
        || warn "$SWAP_PART has TYPE='${swaptype:-?}' — expected swap (was it formatted by stage 1?)."
    swap_uuid="$(uuid_of "$SWAP_PART")"
    if [[ -n "$swap_uuid" ]]; then
        grep -Fq "$swap_uuid" "$HW_TMP" \
            || die "hardware detection missed dedicated swap $SWAP_PART (UUID $swap_uuid)."
        echo "  dedicated swap $SWAP_PART is reflected in the hardware configuration."
    else
        warn "could not read a UUID for $SWAP_PART — swap may not appear in the hardware configuration."
    fi
fi

# ------------------------------------------------------------
# Write into the target checkout
# ------------------------------------------------------------

TARGET_HW="$TARGET_FLAKE/hosts/$HOST/hardware-configuration.nix"
mkdir -p "$TARGET_FLAKE/hosts/$HOST"

{
    echo "# Generated by the installer (stage 2) on $(date --iso-8601=seconds)."
    echo "# Machine-specific hardware + filesystem layout produced by:"
    echo "#   nixos-generate-config --root $TARGET --show-hardware-config"
    echo "# Do not hand-edit hardware values here; regenerate them instead."
    echo "# System policy lives in the flake ($TARGET_FLAKE)."
    echo
    cat "$HW_TMP"
} > "$TARGET_HW"

rm -f "$HW_TMP"
trap - EXIT

echo
info "Wrote hardware configuration:"
echo "  target: $TARGET_HW"

# ------------------------------------------------------------
# Keep the source repo coherent — deliberately, not destructively
# ------------------------------------------------------------

SOURCE_HW="$REPO_DIR/hosts/$HOST/hardware-configuration.nix"
mkdir -p "$REPO_DIR/hosts/$HOST"

if [[ -f "$SOURCE_HW" ]]; then
    if cmp -s "$SOURCE_HW" "$TARGET_HW"; then
        echo "  source: $SOURCE_HW (unchanged)"
    elif yesno "Source repo already has $SOURCE_HW. Overwrite it (a backup is kept)?"; then
        cp "$SOURCE_HW" "$SOURCE_HW.last-install.bak"
        cp "$TARGET_HW" "$SOURCE_HW"
        echo "  source: $SOURCE_HW (updated; backup at $SOURCE_HW.last-install.bak)"
    else
        warn "source repository hardware config left untouched."
    fi
else
    cp "$TARGET_HW" "$SOURCE_HW"
    echo "  source: $SOURCE_HW (created)"
fi

# ------------------------------------------------------------
# Seed /persistent for Impermanence
# ------------------------------------------------------------
#
# modules/system/impermanence.nix bind-mounts these exact paths from
# @persistent (-> /persistent) into the impermanent root at boot, via
# nix-community/impermanence's environment.persistence."/persistent".
# Keep this list in sync with that module.

section "SEEDING /persistent (IMPERMANENCE)"

mkdir -p \
    "$TARGET/persistent/etc/ssh" \
    "$TARGET/persistent/etc/NetworkManager/system-connections" \
    "$TARGET/persistent/var/lib" \
    "$TARGET/persistent/var/lib/bluetooth" \
    "$TARGET/persistent/var/lib/docker" \
    "$TARGET/persistent/var/lib/flatpak" \
    "$TARGET/persistent/var/lib/libvirt" \
    "$TARGET/persistent/var/lib/nixos" \
    "$TARGET/persistent/var/log" \
    "$TARGET/persistent/root" \
    "$TARGET/persistent/var/cache/tuigreet"

# Pre-generate stable SSH host keys so they survive the root wipe on reboot.
# modules/system/impermanence.nix bind-mounts these directly (safe for keys —
# nothing rewrites them in place once present; sshd's keygen unit only
# generates them if missing).
for kind in ed25519 rsa; do
    key="$TARGET/persistent/etc/ssh/ssh_host_${kind}_key"
    if [[ ! -f "$key" ]]; then
        echo "  generating SSH host key: ${kind}"
        ssh-keygen -q -t "$kind" -N "" -f "$key" -C "root@$HOST"
        chmod 600 "$key"
        chmod 600 "$key.pub"
    fi
done

# /etc/machine-id is also persisted; nixos-install generates the real one
# inside the target root during stage 4, so just make sure the mountpoint
# exists here — the file itself is created (and thus persisted) at boot.
touch "$TARGET/persistent/etc/machine-id" 2>/dev/null || true

# /var/lib/systemd/random-seed is persisted too (see the files list in
# modules/system/impermanence.nix). Pre-create the (empty) backing file so
# the persistence unit can bind-mount it directly on first boot instead of
# falling back to a symlink; systemd rewrites it with a real seed at runtime.
mkdir -p "$TARGET/persistent/var/lib/systemd"
touch "$TARGET/persistent/var/lib/systemd/random-seed"

# ------------------------------------------------------------
# Account passwords — REQUIRED, not optional
# ------------------------------------------------------------
#
# users.mutableUsers = false; (see modules/users/aul/aul.nix) means both
# accounts are declarative-only: hashedPasswordFile is the ONLY way either
# gets a password, and it has to exist BEFORE nixos-install's first
# activation runs (stage 4), or both root and $TARGET_USER boot with no
# valid password at all — full lockout, recoverable only by chrooting from
# this same ISO. Interactive `passwd` after the fact does not work once
# mutableUsers=false (NixOS overwrites /etc/shadow from Nix state on every
# activation, so an interactive change doesn't survive even the next
# rebuild, let alone a reboot). This has to happen here in stage 2, not
# stage 4 — stage 3's validation checks for these files existing.

section "SETTING ACCOUNT PASSWORDS (REQUIRED)"

echo "Both 'root' and '$TARGET_USER' need a password set now — this flake"
echo "manages passwords declaratively (users.mutableUsers = false), so"
echo "there is no working interactive fallback afterward."
echo

set_account_password_hash() {
    local username="$1" hashfile="$2"
    local pass1 pass2
    if [[ -s "$hashfile" ]]; then
        echo "  $username: hash already exists at $hashfile, skipping (delete it first to reset)"
        return
    fi
    while true; do
        read -rs -p "Password for $username: " pass1
        echo
        read -rs -p "Retype password for $username: " pass2
        echo
        if [[ -z "$pass1" ]]; then
            echo "Password cannot be empty."
        elif [[ "$pass1" != "$pass2" ]]; then
            echo "Passwords didn't match."
        else
            break
        fi
    done
    mkdir -p "$(dirname "$hashfile")"
    printf '%s' "$pass1" \
        | nix --extra-experimental-features 'nix-command flakes' run nixpkgs#mkpasswd -- -m sha-512 -s \
        > "$hashfile"
    chmod 600 "$hashfile"
    unset pass1 pass2
}

mkdir -p "$TARGET/persistent/etc/users"
set_account_password_hash "root" "$TARGET/persistent/etc/users/root.hash"
set_account_password_hash "$TARGET_USER" "$TARGET/persistent/etc/users/$TARGET_USER.hash"

echo
info "Password hashes written under $TARGET/persistent/etc/users/."

# ------------------------------------------------------------
# Seed /persistent/home/$TARGET_USER for the per-user whitelist
# ------------------------------------------------------------
#
# $HOME lives inside @, which is wiped back to blank on every boot (full
# desktop impermanence — see modules/system/impermanence.nix).
# environment.persistence."/persistent".users.aul (also in that file)
# bind-mounts these exact paths back into $HOME. Keep this list in sync
# with that module. Directories are created empty; the flake itself was
# already copied above (it lives directly under this tree, at
# $TARGET_FLAKE).

mkdir -p \
    "$TARGET/persistent/home/$TARGET_USER/Downloads" \
    "$TARGET/persistent/home/$TARGET_USER/Documents" \
    "$TARGET/persistent/home/$TARGET_USER/Pictures" \
    "$TARGET/persistent/home/$TARGET_USER/Videos" \
    "$TARGET/persistent/home/$TARGET_USER/Music" \
    "$TARGET/persistent/home/$TARGET_USER/.ssh" \
    "$TARGET/persistent/home/$TARGET_USER/.gnupg" \
    "$TARGET/persistent/home/$TARGET_USER/.config/gh" \
    "$TARGET/persistent/home/$TARGET_USER/.librewolf" \
    "$TARGET/persistent/home/$TARGET_USER/.config/vesktop" \
    "$TARGET/persistent/home/$TARGET_USER/.config/Code" \
    "$TARGET/persistent/home/$TARGET_USER/.vscode" \
    "$TARGET/persistent/home/$TARGET_USER/.local/share/JetBrains" \
    "$TARGET/persistent/home/$TARGET_USER/.config/JetBrains" \
    "$TARGET/persistent/home/$TARGET_USER/.local/share/Steam" \
    "$TARGET/persistent/home/$TARGET_USER/.steam" \
    "$TARGET/persistent/home/$TARGET_USER/.local/share/PrismLauncher" \
    "$TARGET/persistent/home/$TARGET_USER/.var/app" \
    "$TARGET/persistent/home/$TARGET_USER/.config/obsidian" \
    "$TARGET/persistent/home/$TARGET_USER/.config/zsh" \
    "$TARGET/persistent/home/$TARGET_USER/.cache/skwd-wall" \
    "$TARGET/persistent/home/$TARGET_USER/.config/skwd-wall"

chmod 700 "$TARGET/persistent/home/$TARGET_USER/.ssh" "$TARGET/persistent/home/$TARGET_USER/.gnupg"

# Sudo's "you've been lectured" marker, so the wall-of-text warning doesn't
# reappear every single boot.
mkdir -p "$TARGET/persistent/var/db/sudo/lectured"

echo
info "Persistent tree seeded under $TARGET/persistent."
info "@ is rolled back to a blank snapshot on every boot (\$HOME lives inside it);"
info "only the paths above (and /nix, plus /persistent itself) survive."

state_save TARGET HOST EFI_PART ROOT_PART SWAP_PART

echo
section "STAGE 2 COMPLETE"
echo
echo "Next stage:"
echo "  sudo $SCRIPT_DIR/03-validate.sh"