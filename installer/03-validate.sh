#!/usr/bin/env bash
# Stage 3 — non-destructive pre-install validation.
#
# This stage VERIFIES, never modifies:
#   - the /mnt mount layout + required Btrfs subvolumes
#   - the generated hardware-configuration.nix (devices derived from the live
#     mounts — never a hardcoded /dev/vda — UUIDs, subvolumes, fsTypes)
#   - the copied flake + host (using the repository's real host structure)
#   - swap state (dedicated partition vs. flake-configured zram/swapfile)
#   - Impermanence status (persistent fs ≠ impermanence module)
#   - that the flake configuration actually evaluates (quick eval, no build)

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

require_root
require_live_iso
require_cmd findmnt mount umount mountpoint blkid btrfs nix stat awk grep

state_load

HOST="${HOST:-}"
if [[ -z "$HOST" ]]; then
    HOST_DEFAULT="$(list_hosts | head -n1)"
    [[ -n "$HOST_DEFAULT" ]] || HOST_DEFAULT="test"
    HOST="$(prompt_default "Host to validate" "$HOST_DEFAULT")"
fi
[[ -n "$HOST" ]] || die "no host name given."
valid_hostname "$HOST" || die "host '$HOST' is not a valid Nix identifier."

set_target_flake "$HOST"

FAILED=0
ok() {
    printf '%s\n' "  [ OK ] $*"
}
fail() {
    FAILED=1
    printf '%s\n' "  [FAIL] $*" >&2
}

section "STAGE 3 — PRE-INSTALL VALIDATION"
echo
echo "This stage is NON-DESTRUCTIVE. Nothing on /mnt is changed."
echo

# ------------------------------------------------------------
# Mounts
# ------------------------------------------------------------

section "MOUNTS"

for m in "$TARGET" "$TARGET/nix" "$TARGET/persistent" "$TARGET/boot"; do
    if mountpoint -q "$m"; then
        ok "mounted: $m  ($(findmnt -no SOURCE "$m" 2>/dev/null | sed 's/\[.*//'))"
    else
        fail "missing mount: $m (run stage 1)"
    fi
done

# ------------------------------------------------------------
# Btrfs subvolumes
# ------------------------------------------------------------

section "BTRFS SUBVOLUMES"

trap release_btrfs_top EXIT
for subvol in "${REQUIRED_SUBVOLS[@]}"; do
    btrfs_subvolume_exists "$subvol" \
        && ok "subvolume: $subvol" \
        || fail "missing Btrfs subvolume: $subvol (run stage 1)"
done
release_btrfs_top
trap - EXIT

# ------------------------------------------------------------
# Hardware configuration
# ------------------------------------------------------------

section "HARDWARE CONFIGURATION"

TARGET_HW="$TARGET_FLAKE/hosts/$HOST/hardware-configuration.nix"

if [[ -f "$TARGET_HW" ]]; then
    ok "hardware configuration exists: $TARGET_HW"
else
    fail "hardware configuration missing: $TARGET_HW (run stage 2)"
fi

# Devices are derived from the CURRENT mounts — never hardcoded.
ROOT_DEV="$(btrfs_dev_of "$TARGET")"
BOOT_DEV="$(findmnt -no SOURCE "$TARGET/boot")"
ROOT_UUID="$(uuid_of "$ROOT_DEV")"
EFI_UUID="$(uuid_of "$BOOT_DEV")"

if [[ -n "$ROOT_DEV" && -n "$ROOT_UUID" ]]; then
    ok "Btrfs device: $ROOT_DEV (UUID $ROOT_UUID)"
else
    fail "could not determine the mounted Btrfs device/UUID."
fi
if [[ -n "$BOOT_DEV" && -n "$EFI_UUID" ]]; then
    ok "EFI device:   $BOOT_DEV (UUID $EFI_UUID)"
else
    fail "could not determine the mounted EFI device/UUID."
fi

if [[ -f "$TARGET_HW" ]]; then
    grep -Fq 'fileSystems."/"' "$TARGET_HW" \
        && ok "filesystem '/' declared" \
        || fail "filesystem '/' not declared in hardware configuration"
    grep -Fq 'fsType = "btrfs"' "$TARGET_HW" \
        && ok "root filesystem is btrfs" \
        || fail "root filesystem is not btrfs"
    for m in /nix /persistent /boot; do
        grep -Fq "fileSystems.\"$m\"" "$TARGET_HW" \
            && ok "filesystem '$m' declared" \
            || fail "filesystem '$m' not declared in hardware configuration"
    done
    for subvol in "${MOUNTED_SUBVOLS[@]}"; do
        grep -Fq "subvol=$subvol" "$TARGET_HW" \
            && ok "subvolume mount $subvol present" \
            || fail "subvolume mount $subvol missing from hardware configuration"
    done
    [[ -n "$ROOT_UUID" ]] && { grep -Fq "$ROOT_UUID" "$TARGET_HW" \
        && ok "Btrfs UUID matches the live device" \
        || fail "Btrfs UUID $ROOT_UUID not found in hardware configuration"; }
    [[ -n "$EFI_UUID" ]] && { grep -Fq "$EFI_UUID" "$TARGET_HW" \
        && ok "EFI UUID matches the live device" \
        || fail "EFI UUID $EFI_UUID not found in hardware configuration"; }
fi

# ------------------------------------------------------------
# Flake + host
# ------------------------------------------------------------

section "FLAKE & HOST"

require_flake && ok "flake present at $TARGET_FLAKE (flake.nix + flake.lock)"

if host_is_in_flake "$TARGET_FLAKE" "$HOST"; then
    ok "host '$HOST' present in the flake structure (modules/hosts.nix + modules/hosts/$HOST/default.nix)"
else
    fail "host '$HOST' not found in $TARGET_FLAKE (run stage 2)"
fi

# ------------------------------------------------------------
# Swap
# ------------------------------------------------------------

section "SWAP"

# 1) Optional dedicated swap partition selected in stage 1.
if [[ -n "${SWAP_PART:-}" ]]; then
    if is_block_device "$SWAP_PART"; then
        ok "dedicated partition: $SWAP_PART"
    else
        fail "dedicated partition: $SWAP_PART is not a block device (selected in stage 1)"
    fi
    swaptype="$(blkid -s TYPE -o value "$SWAP_PART" 2>/dev/null || true)"
    if [[ "$swaptype" == "swap" ]]; then
        ok "dedicated partition is swap (TYPE=swap)"
    else
        fail "dedicated partition $SWAP_PART has TYPE='${swaptype:-?}' — not swap"
    fi
    if awk 'NR>1 { print $1 }' /proc/swaps 2>/dev/null | grep -qx "$SWAP_PART"; then
        ok "dedicated partition is active swap"
    else
        warn "dedicated partition exists but is not active — run 'swapon $SWAP_PART'"
    fi
    swap_uuid="$(uuid_of "$SWAP_PART")"
    if [[ -n "$swap_uuid" ]]; then
        grep -Fq "$swap_uuid" "$TARGET_HW" 2>/dev/null \
            && ok "dedicated swap is declared in the hardware configuration" \
            || fail "dedicated swap $SWAP_PART (UUID $swap_uuid) missing from the hardware configuration"
    else
        warn "no UUID available for $SWAP_PART — cannot verify it in the hardware configuration"
    fi
fi

# 2) Flake-configured swap (zram / swapfile).  Verified statically: only
#    reported when this host actually includes the swap aspect AND the flake
#    source contains the corresponding configuration.
host_includes_aspect() {
    local base="$1" host="$2" aspect="$3"
    [[ -f "$base/modules/hosts/$host/default.nix" ]] || return 1
    grep -Eq "den\.aspects\.${aspect}\b" "$base/modules/hosts/$host/default.nix" 2>/dev/null
}
flake_source_has() {  # <base flake dir> <pattern>
    grep -RIq -- "$2" "$1/modules" "$1/flake.nix" 2>/dev/null
}

if host_includes_aspect "$TARGET_FLAKE" "$HOST" swap; then
    flake_source_has "$TARGET_FLAKE" "zramSwap" \
        && ok "zram:      configured by flake" \
        || warn "zram:      not configured by flake"
    flake_source_has "$TARGET_FLAKE" "swapfile" \
        && ok "swapfile:  configured by flake" \
        || warn "swapfile:  not configured by flake"
else
    warn "host '$HOST' does not include the swap aspect — no zram/swapfile report"
fi

if [[ -z "${SWAP_PART:-}" ]] && ! host_includes_aspect "$TARGET_FLAKE" "$HOST" swap; then
    warn "no swap configured anywhere: no dedicated partition selected, and the host does not include the swap aspect"
fi

# ------------------------------------------------------------
# Impermanence
# ------------------------------------------------------------

section "IMPERMANENCE"

mountpoint -q "$TARGET/persistent" \
    && ok "persistent filesystem (/persistent): existence OK" \
    || fail "persistent filesystem (/persistent) is not mounted (run stage 1)"
grep -Fq 'fileSystems."/persistent"' "$TARGET_HW" 2>/dev/null \
    && ok "/persistent declared in hardware configuration" \
    || fail "/persistent not declared in hardware configuration"

btrfs_subvolume_exists "@blank" \
    && ok "@blank rollback snapshot exists" \
    || fail "@blank subvolume missing — root (and \$HOME, which lives inside it) will NOT be wiped on boot (run stage 1)"

if host_includes_aspect "$TARGET_FLAKE" "$HOST" impermanence; then
    ok "host '$HOST' includes den.aspects.impermanence"
else
    fail "host '$HOST' does not include den.aspects.impermanence — /persistent is prepared, but nothing is bound to it and root will NOT be wiped on boot"
fi
flake_source_has "$TARGET_FLAKE" "nixosModules.impermanence" \
    && ok "impermanence module: imported" \
    || fail "impermanence module: not imported by modules/system/impermanence.nix"
flake_source_has "$TARGET_FLAKE" "environment.persistence" \
    && ok "environment.persistence: configured" \
    || fail "environment.persistence: not configured"
flake_source_has "$TARGET_FLAKE" "users.aul" \
    && ok "per-user whitelist configured (environment.persistence.\"/persistent\".users.aul)" \
    || fail "per-user whitelist not configured — nothing in \$HOME would survive a reboot"
flake_source_has "$TARGET_FLAKE" "users.mutableUsers = false" \
    && ok "declarative passwords enabled (users.mutableUsers = false)" \
    || fail "users.mutableUsers = false not set — see modules/users/aul/aul.nix; interactive passwd doesn't survive a wipe"
if [[ -f "$TARGET/persistent/etc/users/root.hash" && -s "$TARGET/persistent/etc/users/root.hash" ]]; then
    ok "root password hash present at /persistent/etc/users/root.hash"
else
    fail "root password hash MISSING or empty — root will have no working password on first boot (see stage 4's password prompt)"
fi
if [[ -f "$TARGET/persistent/etc/users/$TARGET_USER.hash" && -s "$TARGET/persistent/etc/users/$TARGET_USER.hash" ]]; then
    ok "'$TARGET_USER' password hash present at /persistent/etc/users/$TARGET_USER.hash"
else
    fail "'$TARGET_USER' password hash MISSING or empty — that account will have no working password on first boot"
fi
grep -Fq 'impermanence.url' "$TARGET_FLAKE/flake.nix" 2>/dev/null \
    && ok "impermanence flake input declared" \
    || fail "impermanence flake input missing from flake.nix (run: nix run .#write-flake)"

# ------------------------------------------------------------
# Evaluation (lightweight — evals the config, does NOT build a system)
# ------------------------------------------------------------

section "EVALUATION CHECK"
echo
echo "Evaluating the host configuration:"
echo "  nix --extra-experimental-features 'nix-command flakes' eval --no-write-lock-file --raw .#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath"
echo
echo "This evaluates the config (fetching flake inputs if needed) but does NOT"
echo "build or download a full system. It may take a few minutes the first time."
if yesno "Run the evaluation check now?"; then
    ( cd "$TARGET_FLAKE" && \
      nix --extra-experimental-features 'nix-command flakes' eval --no-write-lock-file --raw \
        ".#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" ) \
        && ok "configuration evaluates" \
        || fail "configuration FAILED to evaluate — fix the flake before installing (log above)"
else
    warn "Evaluation skipped. Everything else above was still verified."
fi

# ------------------------------------------------------------
# Result
# ------------------------------------------------------------

echo
if [[ "$FAILED" -eq 1 ]]; then
    die "validation finished with FAILURES — fix them before installing."
fi
section "STAGE 3 COMPLETE — READY TO INSTALL"
echo
echo "Next stage:"
echo "  sudo $SCRIPT_DIR/04-install.sh"