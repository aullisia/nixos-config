#!/usr/bin/env bash
# Stage 4 — the actual NixOS installation.
#
# This is the ONLY stage that installs. It verifies the prepared target tree
# (mounts, flake, host, hardware configuration, filesystem layout, optional
# dedicated swap) and then runs:
#
#   nixos-install --root /mnt --flake /mnt/persistent/home/<user>/new-nix-config#<host>
#
# It does NOT recopy the flake, does NOT delete the generated hardware
# configuration, and does NOT touch the source repository.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

require_root
require_live_iso
require_cmd nixos-install nixos-enter findmnt blkid btrfs mount umount mountpoint stat awk grep

state_load

HOST="${HOST:-}"
if [[ -z "$HOST" ]]; then
    HOST_DEFAULT="$(list_hosts | head -n1)"
    [[ -n "$HOST_DEFAULT" ]] || HOST_DEFAULT="test"
    HOST="$(prompt_default "Host to install" "$HOST_DEFAULT")"
fi
[[ -n "$HOST" ]] || die "no host name given."
valid_hostname "$HOST" || die "host '$HOST' is not a valid Nix identifier."

set_target_flake "$HOST"

section "STAGE 4 — INSTALLATION"

# ------------------------------------------------------------
# Verify the prepared target tree
# ------------------------------------------------------------

info "Verifying mounts..."
require_mounts \
    "$TARGET" \
    "$TARGET/nix" \
    "$TARGET/persistent" \
    "$TARGET/boot"

info "Verifying flake..."
require_flake

info "Verifying host '$HOST'..."
host_is_in_flake "$TARGET_FLAKE" "$HOST" \
    || die "host '$HOST' not found in $TARGET_FLAKE (run stage 2)."

TARGET_HW="$TARGET_FLAKE/hosts/$HOST/hardware-configuration.nix"
[[ -f "$TARGET_HW" ]] || die "hardware configuration missing: $TARGET_HW (run stage 2)."

info "Verifying filesystem structure in the hardware configuration..."
for fs in 'fileSystems."/"' 'fileSystems."/nix"' 'fileSystems."/persistent"' 'fileSystems."/boot"'; do
    grep -Fq "$fs" "$TARGET_HW" || die "hardware configuration is missing $fs."
done
for subvol in "${MOUNTED_SUBVOLS[@]}"; do
    grep -Fq "subvol=$subvol" "$TARGET_HW" || die "hardware configuration is missing subvolume $subvol."
done

info "Verifying required subvolumes on disk..."
trap release_btrfs_top EXIT
for subvol in "${REQUIRED_SUBVOLS[@]}"; do
    require_subvolume "$subvol"
done
release_btrfs_top
trap - EXIT

# Optional dedicated swap: only a warning here — if the flake turns it off, so
# be it; if it should be on, the user sees it now.
if [[ -n "${SWAP_PART:-}" ]]; then
    swaptype="$(blkid -s TYPE -o value "$SWAP_PART" 2>/dev/null || true)"
    if [[ "$swaptype" != "swap" ]]; then
        warn "$SWAP_PART no longer looks like swap (TYPE='${swaptype:-?}') — the target will not enable it."
    else
        info "dedicated swap present: $SWAP_PART"
    fi
fi

# ------------------------------------------------------------
# Install
# ------------------------------------------------------------

echo
echo "About to install:"
echo "  Host:      $HOST"
echo "  Root:      $TARGET"
echo "  Flake:     $TARGET_FLAKE"
echo "  Hardware:  $TARGET_HW"
echo "  Btrfs:     $(btrfs_dev_of "$TARGET" 2>/dev/null || echo '?')"
echo
echo "nixos-install will build your system. This can take a long time on the"
echo "first install and assumes the machine has network access."
echo

if ! yesno "Start the installation now?"; then
    echo "Installation cancelled."
    exit 0
fi

echo
info "Installing NixOS (this can take a while)..."
nixos-install \
    --root "$TARGET" \
    --flake "$TARGET_FLAKE#$HOST" \
    --no-root-passwd

echo
info "Installation finished."

# ------------------------------------------------------------
# The persistent tree under /persistent/home/$TARGET_USER (flake copy
# included) is currently root-owned (the user didn't exist until
# nixos-install just created it). Fix ownership now that it does — this is
# the backing store that environment.persistence."/persistent".users.aul
# bind-mounts into $HOME on every boot, so it has to be owned by the user,
# not root.
# ------------------------------------------------------------

info "Fixing ownership of /persistent/home/$TARGET_USER (user: $TARGET_USER)..."
if nixos-enter --root "$TARGET" -- id -u "$TARGET_USER" >/dev/null 2>&1; then
    nixos-enter --root "$TARGET" -- chown -R "$TARGET_USER:users" "/persistent/home/$TARGET_USER"
else
    warn "user '$TARGET_USER' does not exist in the installed system — leaving /persistent/home/$TARGET_USER root-owned."
fi

# ------------------------------------------------------------
# Done
# ------------------------------------------------------------

state_save TARGET HOST EFI_PART ROOT_PART SWAP_PART

echo
section "STAGE 4 COMPLETE — READY TO REBOOT"
echo
echo "Next steps:"
echo "  umount -R $TARGET"
echo "  reboot"
echo
echo "Note: / (@) is wiped back to a blank snapshot on every boot — \$HOME"
echo "lives inside it too (not a separate subvolume), so it's wiped along"
echo "with everything else under /. Only /nix, and the paths explicitly"
echo "bound from /persistent (system-wide) and"
echo "/persistent/home/$TARGET_USER (per-user) survive. See"
echo "modules/system/impermanence.nix's environment.persistence config if"
echo "you need to persist more."