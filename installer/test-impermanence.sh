#!/usr/bin/env bash
# Impermanence round-trip test.
#
# Usage:
#   sudo ./installer/test-impermanence.sh seed    # before reboot
#   sudo reboot
#   sudo ./installer/test-impermanence.sh check   # after logging back in
#
# `seed` drops a canary file into every path that SHOULD survive a reboot
# (per modules/system/impermanence.nix's environment.persistence config),
# plus a few paths that should NOT survive (plain, un-whitelisted locations
# under / and $HOME). `check` verifies both halves after a reboot: every
# persisted canary present, every ephemeral canary gone.
#
# IMPORTANT: PERSIST_DIRS_USER / PERSIST_FILES_USER / PERSIST_DIRS_SYSTEM
# below are a manual mirror of modules/system/impermanence.nix's
# environment.persistence lists — this script doesn't read the flake, so if
# you edit one, edit the other. A stale list here just means this script
# stops being a meaningful test, not that impermanence itself is broken.

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Must run as root (sudo)." >&2
    exit 1
fi

TARGET_USER="aul"
HOME_DIR="/home/$TARGET_USER"
CANARY_NAME=".impermanence-test-canary"
MARKER_CONTENT="impermanence-test-$(date +%s)"

# ------------------------------------------------------------
# Mirrors modules/system/impermanence.nix — keep in sync
# ------------------------------------------------------------

PERSIST_DIRS_SYSTEM=(
    /etc/NetworkManager/system-connections
    /var/lib/bluetooth
    /var/lib/docker
    /var/lib/libvirt
    /var/lib/nixos
    /var/log
    /root
    /var/db/sudo/lectured
    /var/cache/tuigreet
    /var/lib/flatpak
)

# Existing files only — never created/modified by this script, just checked
# for continued existence + non-empty content. Safe to touch nothing here:
# these are real system files (ssh host keys, machine-id) that already
# exist on any correctly-configured install.
PERSIST_FILES_SYSTEM=(
    /etc/machine-id
    /etc/ssh/ssh_host_ed25519_key
    /etc/ssh/ssh_host_ed25519_key.pub
    /etc/ssh/ssh_host_rsa_key
    /etc/ssh/ssh_host_rsa_key.pub
    /var/lib/systemd/random-seed
)

PERSIST_DIRS_USER=(
    Downloads
    Documents
    Pictures
    Videos
    Music
    nixos-config
    .ssh
    .gnupg
    .local/share/keyrings
    .config/gh
    .librewolf
    .config/vesktop
    .config/Code
    .vscode
    .local/share/JetBrains
    .config/JetBrains
    .local/share/Steam
    .steam
    .local/share/PrismLauncher
    .var/app
    .config/obsidian
    .config/zsh
    .local/state/noctalia
    .config/blender
)

PERSIST_FILES_USER=()

# Paths that should NOT survive — plain locations under the wiped root,
# nothing to do with the whitelist above.
EPHEMERAL_DIRS=(
    "/var/impermanence-test-ephemeral-dir"
    "$HOME_DIR/impermanence-test-ephemeral-dir"
)
EPHEMERAL_FILES=(
    "/THIS_SHOULD_DISAPPEAR"
    "$HOME_DIR/THIS_SHOULD_ALSO_DISAPPEAR"
    "/etc/impermanence-test-ephemeral-file"
)

# ------------------------------------------------------------

seed() {
    echo "Seeding canary files..."

    for d in "${PERSIST_DIRS_SYSTEM[@]}"; do
        mkdir -p "$d"
        echo "$MARKER_CONTENT" > "$d/$CANARY_NAME"
    done

    for d in "${PERSIST_DIRS_USER[@]}"; do
        mkdir -p "$HOME_DIR/$d"
        echo "$MARKER_CONTENT" > "$HOME_DIR/$d/$CANARY_NAME"
        chown "$TARGET_USER:users" "$HOME_DIR/$d/$CANARY_NAME"
    done

    for f in "${PERSIST_FILES_USER[@]}"; do
        [[ -e "$HOME_DIR/$f" ]] || { touch "$HOME_DIR/$f"; chown "$TARGET_USER:users" "$HOME_DIR/$f"; }
    done

    for d in "${EPHEMERAL_DIRS[@]}"; do
        mkdir -p "$d"
        echo "$MARKER_CONTENT" > "$d/$CANARY_NAME"
    done

    for f in "${EPHEMERAL_FILES[@]}"; do
        mkdir -p "$(dirname "$f")"
        echo "$MARKER_CONTENT" > "$f"
    done

    echo
    echo "Seeded. Now:"
    echo "  sudo reboot"
    echo "  (log back in)"
    echo "  sudo $0 check"
}

check() {
    local failures=0
    local checked=0

    echo "== Persisted paths (must ALL still exist) =="

    for d in "${PERSIST_DIRS_SYSTEM[@]}"; do
        checked=$((checked + 1))
        if [[ -f "$d/$CANARY_NAME" ]]; then
            echo "  OK    $d"
        else
            echo "  FAIL  $d  (canary missing — not persisted!)"
            failures=$((failures + 1))
        fi
    done

    for f in "${PERSIST_FILES_SYSTEM[@]}"; do
        checked=$((checked + 1))
        if [[ -s "$f" ]]; then
            echo "  OK    $f"
        else
            echo "  FAIL  $f  (missing or empty!)"
            failures=$((failures + 1))
        fi
    done

    for d in "${PERSIST_DIRS_USER[@]}"; do
        checked=$((checked + 1))
        if [[ -f "$HOME_DIR/$d/$CANARY_NAME" ]]; then
            echo "  OK    ~/$d"
        else
            echo "  FAIL  ~/$d  (canary missing — not persisted!)"
            failures=$((failures + 1))
        fi
    done

    for f in "${PERSIST_FILES_USER[@]}"; do
        checked=$((checked + 1))
        if [[ -e "$HOME_DIR/$f" ]]; then
            echo "  OK    ~/$f"
        else
            echo "  FAIL  ~/$f  (missing!)"
            failures=$((failures + 1))
        fi
    done

    echo
    echo "== Ephemeral paths (must ALL be gone) =="

    for d in "${EPHEMERAL_DIRS[@]}"; do
        checked=$((checked + 1))
        if [[ -e "$d" ]]; then
            echo "  FAIL  $d  (still exists — wipe didn't happen!)"
            failures=$((failures + 1))
        else
            echo "  OK    $d  (gone)"
        fi
    done

    for f in "${EPHEMERAL_FILES[@]}"; do
        checked=$((checked + 1))
        if [[ -e "$f" ]]; then
            echo "  FAIL  $f  (still exists — wipe didn't happen!)"
            failures=$((failures + 1))
        else
            echo "  OK    $f  (gone)"
        fi
    done

    echo
    clean

    if [[ $failures -eq 0 ]]; then
        echo "ALL $checked CHECKS PASSED."
    else
        echo "$failures / $checked CHECK(S) FAILED."
        exit 1
    fi
}

# Removes every canary file this script's own `seed` created — both the
# ones sitting in persisted directories (which, unlike the ephemeral test
# paths, do NOT get cleaned up by a reboot; they'd otherwise sit there
# forever) and any leftover ephemeral test artifacts (in case a previous
# `check` failed and a reboot never actually cleared them). Called
# automatically at the end of `check`; also available standalone if a run
# gets interrupted between `seed` and `check`.
clean() {
    local removed=0

    for d in "${PERSIST_DIRS_SYSTEM[@]}"; do
        if [[ -f "$d/$CANARY_NAME" ]]; then
            rm -f "$d/$CANARY_NAME"
            removed=$((removed + 1))
        fi
    done

    for d in "${PERSIST_DIRS_USER[@]}"; do
        if [[ -f "$HOME_DIR/$d/$CANARY_NAME" ]]; then
            rm -f "$HOME_DIR/$d/$CANARY_NAME"
            removed=$((removed + 1))
        fi
    done

    for d in "${EPHEMERAL_DIRS[@]}"; do
        if [[ -e "$d" ]]; then
            rm -rf "$d"
            removed=$((removed + 1))
        fi
    done

    for f in "${EPHEMERAL_FILES[@]}"; do
        if [[ -e "$f" ]]; then
            rm -f "$f"
            removed=$((removed + 1))
        fi
    done

    echo "Cleaned up $removed leftover test artifact(s)."
}

case "${1:-}" in
    seed) seed ;;
    check) check ;;
    clean) clean ;;
    *)
        echo "usage: $0 {seed|check|clean}" >&2
        exit 1
        ;;
esac