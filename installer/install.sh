#!/usr/bin/env bash
# NixOS installer — master entry point.
#
# Usage:
#   sudo ./install.sh
#   sudo ./install.sh <host>
#   sudo ./install.sh <host> format
#   sudo ./install.sh <host> configure
#   sudo ./install.sh <host> validate
#   sudo ./install.sh <host> install
#
#   host    optional host name (default: the one saved in state, else the
#           first registered host in the flake)
#   stage   optional single stage to run; default runs all four in order
#
# Typical flow — a single command handles everything:
#   1. Boot the NixOS installer ISO.
#   2. Partition in GParted (ESP + btrfs + optional dedicated swap).
#   3. sudo ./install.sh <host>
#
# The master script passes state between stages via /run/new-nixos-installer
# and pauses between stages so you can review what happened.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

require_root
require_live_iso

HOST_ARG="${1:-}"
STAGE="${2:-all}"

state_load
HOST="${HOST_ARG:-${HOST:-}}"

if [[ -z "$HOST" ]]; then
    HOST_DEFAULT="$(list_hosts | head -n1)"
    [[ -n "$HOST_DEFAULT" ]] || HOST_DEFAULT="test"
    HOST="$(prompt_default "Host name" "$HOST_DEFAULT")"
fi
[[ -n "$HOST" ]] || die "no host name given."
valid_hostname "$HOST" || die "host '$HOST' is not a valid Nix identifier."

set_target_flake "$HOST"
state_save TARGET HOST EFI_PART ROOT_PART SWAP_PART

section "NIXOS INSTALLER"
echo
echo "  Host:   $HOST"
echo "  Root:   $TARGET"
echo "  Flake:  $REPO_DIR  (source; copied to $TARGET_FLAKE by stage 2)"
echo
echo "  stage 1  format   : format EFI/btrfs/(optional)swap, create subvolumes, mount /mnt"
echo "  stage 2  configure: copy source flake, generate REAL hardware config, seed /persistent"
echo "  stage 3  validate : non-destructive checks + flake evaluation"
echo "  stage 4  install  : nixos-install + optional user password"
echo

run_stage() {
    local script="$SCRIPT_DIR/$1"
    [[ -x "$script" ]] || die "missing stage script: $script"
    echo
    "$script"
}

case "$STAGE" in
    format)
        run_stage 01-format.sh
        ;;
    configure)
        run_stage 02-configure.sh
        ;;
    validate)
        run_stage 03-validate.sh
        ;;
    install)
        run_stage 04-install.sh
        ;;
    all)
        run_stage 01-format.sh
        pause

        run_stage 02-configure.sh
        pause

        # Validation performs its own checks; it may ask whether to run the
        # (potentially network-fetching) evaluation. Then confirm install.
        run_stage 03-validate.sh

        if yesno "Proceed to the destructive NixOS installation?"; then
            run_stage 04-install.sh
        else
            echo
            warn "Installation skipped. Mounts are ready; run stage 4 later."
        fi
        ;;
    *)
        die "unknown stage '$STAGE' (valid: all format configure validate install)."
        ;;
esac

echo
section "INSTALLER SCRIPT FINISHED"

if [[ "$STAGE" != "all" ]]; then
    echo
    echo "Current mounts under $TARGET:"
    findmnt -R "$TARGET" 2>/dev/null || true
fi
echo