#!/usr/bin/env bash
# Shared helpers used by every installer stage.

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths.  SCRIPT_DIR is the installer directory; REPO_DIR is the source flake
# repository that contains it (e.g. /home/<user>/nixos-config).  The source
# repository is NEVER the target checkout under /mnt — that only exists after
# stage 2 copies the files.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

TARGET="/mnt"

# TARGET_FLAKE is NOT static: the flake is installed under the target user's
# home directory (on the persistent @persistent subvolume), so it depends on
# which host/user is selected. Call set_target_flake() as soon as HOST is
# known; every stage does this before TARGET_FLAKE is first used.
TARGET_FLAKE=""
TARGET_USER=""
DEFAULT_USER="aul"

STATE_DIR="/run/new-nixos-installer"
STATE_FILE="$STATE_DIR/state"
BTRFS_TOP="$STATE_DIR/btrfs"

# The layout created by stage 1 and required by every later stage.
# @blank is a pristine, empty snapshot used to roll @ back to a clean state
# on every boot (see modules/system/impermanence.nix). It is deliberately
# never mounted, so it never appears in the generated
# hardware-configuration.nix — use MOUNTED_SUBVOLS for anything checking
# fileSystems/mount entries, and REQUIRED_SUBVOLS for on-disk existence.
# NOTE: /home is NOT a separate subvolume — it's an ordinary directory
# inside @.
REQUIRED_SUBVOLS=(@ @nix @persistent @blank)
MOUNTED_SUBVOLS=(@ @nix @persistent)

C_RED=$'\033[1;31m'
C_GREEN=$'\033[1;32m'
C_YELLOW=$'\033[1;33m'
C_BLUE=$'\033[1;34m'
C_RESET=$'\033[0m'

info() {
    printf '%s\n' "${C_GREEN}==>${C_RESET} $*"
}

warn() {
    printf '%s\n' "${C_YELLOW}WARN:${C_RESET} $*" >&2
}

die() {
    printf '%s\n' "${C_RED}ERROR:${C_RESET} $*" >&2
    exit 1
}

section() {
    printf '%s\n' "$C_BLUE"
    printf '================================================================\n'
    printf '  %s\n' "$1"
    printf '================================================================%s\n' "$C_RESET"
}

require_root() {
    [[ $EUID -eq 0 ]] || die "run this script with sudo/root."
}

# Every stage of this installer assumes it's running from the NixOS
# installer/live ISO against a target disk mounted at /mnt — never against
# an already-installed, currently-running system. Since installer/ is now
# kept on the deployed copy of the flake (for scripts like
# test-impermanence.sh), there's a real risk of someone accidentally
# re-running e.g. 01-format.sh from an installed system and wiping their
# real disk. Detect live media with two independent signals (either is
# enough): the install medium is conventionally mounted at /iso, and a live
# ISO's root filesystem is an overlay/tmpfs, never a real persistent one.
is_live_iso() {
    mountpoint -q /iso 2>/dev/null && return 0
    case "$(findmnt -no FSTYPE / 2>/dev/null || true)" in
        overlay | tmpfs | aufs) return 0 ;;
    esac
    return 1
}

require_live_iso() {
    is_live_iso || die "this does not look like the NixOS installer/live ISO (no /iso mount, and / is not an overlay/tmpfs filesystem). Refusing to run: this script is destructive and must only be run from install media, never against an already-installed system."
}

require_cmd() {
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || die "required tool '$cmd' is not available."
    done
}

pause() {
    echo
    read -rp "Press Enter to continue..."
}

yesno() {
    local answer
    read -rp "$* [y/N]: " answer
    case "${answer:-n}" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

prompt_default() {
    local prompt="$1" default="$2" answer
    read -rp "${prompt} [${default}]: " answer
    [[ -z "$answer" ]] && answer="$default"
    printf '%s' "$answer"
}

confirm_wipe() {
    local answer
    read -rp "Type WIPE to continue: " answer
    [[ "$answer" == "WIPE" ]] || die "aborted — nothing was changed."
}

# ---------------------------------------------------------------------------
# State.  Persisted under /run/new-nixos-installer so stages hand each other
# the selected host, EFI/root/swap devices, etc.
# ---------------------------------------------------------------------------

state_save() {
    local var value
    mkdir -p "$STATE_DIR"
    touch "$STATE_FILE"
    for var in "$@"; do
        value="${!var:-}"
        sed -i "/^${var}=/d" "$STATE_FILE"
        printf '%s=%s\n' "$var" "$value" >> "$STATE_FILE"
    done
}

state_load() {
    local k v
    [[ -f "$STATE_FILE" ]] || return 0
    while IFS='=' read -r k v; do
        [[ -n "$k" ]] || continue
        printf -v "$k" '%s' "$v"
    done < "$STATE_FILE"
}

# ---------------------------------------------------------------------------
# Mounts / flakes
# ---------------------------------------------------------------------------

require_mount() {
    mountpoint -q "$1" || die "required mount is missing: $1"
}

require_mounts() {
    local m
    for m in "$@"; do
        require_mount "$m"
    done
}

# Determine the primary user for <host> by reading its registration in
# modules/hosts.nix (e.g. "test = { users.aul = aul; ... };" -> "aul").
detect_target_user() {
    local base="$1" host="$2"
    awk -v h="$host" '
        $0 ~ ("^[[:space:]]*" h "[[:space:]]*=[[:space:]]*\\{") { inhost = 1; next }
        inhost && /^[[:space:]]*\};/ { exit }
        inhost && /users\./ { n = split($1, a, "."); print a[2]; exit }
    ' "$base/modules/hosts.nix" 2>/dev/null
}

# Sets TARGET_USER and TARGET_FLAKE for the resolved host. Must be called
# after HOST is known and before TARGET_FLAKE is used.
#
# The flake is stored at /persistent/home/<user>/nixos-config — i.e. on the
# @persistent subvolume, NOT directly under /home. Since $HOME lives inside
# @, which is wiped back to blank on every boot (see
# modules/system/impermanence.nix), anything written straight to /home would
# vanish on first reboot; environment.persistence."/persistent".users.<user>
# bind-mounts this backing path back to ~/nixos-config after each wipe, so
# it still shows up exactly where the user expects it.
set_target_flake() {
    local host="$1"
    TARGET_USER="$(detect_target_user "$REPO_DIR" "$host")"
    [[ -n "$TARGET_USER" ]] || TARGET_USER="$DEFAULT_USER"
    TARGET_FLAKE="$TARGET/persistent/home/$TARGET_USER/nixos-config"
}

# The flake under the target root — what nixos-install will actually consume.
require_flake() {
    [[ -f "$TARGET_FLAKE/flake.nix" ]] || die "flake.nix not found at $TARGET_FLAKE."
    [[ -f "$TARGET_FLAKE/flake.lock" ]] || die "flake.lock not found at $TARGET_FLAKE."
}

# The *source* repository that lives outside /mnt (e.g. /home/<user>).
require_source_flake() {
    [[ -f "$REPO_DIR/flake.nix" ]] || die "source repository is not a flake: missing $REPO_DIR/flake.nix."
    if [[ ! -f "$REPO_DIR/flake.lock" ]]; then
        warn "source repository has no flake.lock yet (the flake may still evaluate, but this is unusual)."
    fi
}

# Guard against ever mistaking the target checkout for the original source.
assert_source_is_not_target() {
    [[ "$REPO_DIR" != "$TARGET_FLAKE" ]] \
        || die "REPO_DIR ($REPO_DIR) must NOT be $TARGET_FLAKE: the source repository has to live outside /mnt (e.g. /home/<user>/nixos-config)."
}

valid_hostname() {
    [[ "$1" =~ ^[a-zA-Z0-9_]+$ ]]
}

# ---------------------------------------------------------------------------
# Hosts.  The repository architecture is:
#   - policy:    modules/hosts/<host>/default.nix
#   - registry:  den.hosts.x86_64-linux.<host> = { ... } in modules/hosts.nix
#   - hardware:  hosts/<host>/hardware-configuration.nix
# We preserve that structure instead of inventing a parallel one.
# ---------------------------------------------------------------------------

# Whether <host> is registered AND has a policy file inside <base> (a flake dir).
host_is_in_flake() {
    local base="$1" host="$2"
    [[ -f "$base/modules/hosts/$host/default.nix" ]] || return 1
    [[ -f "$base/modules/hosts.nix" ]] || return 1
    grep -Fq "den.hosts.x86_64-linux" "$base/modules/hosts.nix" 2>/dev/null || return 1
    awk -v h="$host" '
        /den\.hosts\.x86_64-linux/ { inhosts = 1 }
        inhosts && $1 == h && $2 == "=" { found = 1 }
        END { exit (found ? 0 : 1) }
    ' "$base/modules/hosts.nix"
}

# Whether the source repo has a policy file for <host>.
host_policy_exists() {
    [[ -f "$REPO_DIR/modules/hosts/$1/default.nix" ]]
}

# Registered hosts in the source repository.
list_hosts() {
    local d
    for d in "$REPO_DIR"/modules/hosts/*/; do
        [[ -d "$d" ]] || continue
        host_is_in_flake "$REPO_DIR" "$(basename "$d")" 2>/dev/null || continue
        basename "$d"
    done | sort -u
}

# ---------------------------------------------------------------------------
# Disk / partition detection (always dynamic; never /dev/vda or similar).
# ---------------------------------------------------------------------------

print_disks() {
    echo
    lsblk -o NAME,SIZE,RO,TYPE,FSTYPE,LABEL,PARTLABEL,MOUNTPOINTS
    echo
}

find_efi_partitions() {
    lsblk -nlo PATH,PARTTYPE \
        | awk '$2 == "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" { print $1 }'
}

suggest_root_partition() {
    local efi_list path fstype size best bestsize
    efi_list="$(find_efi_partitions | tr '\n' ' ')"
    best=""
    bestsize=0
    while read -r path fstype size; do
        [[ -b "$path" ]] || continue
        [[ " $efi_list " == *" $path "* ]] && continue
        findmnt -n -o TARGET "$path" >/dev/null 2>&1 && continue
        [[ -n "$fstype" ]] && continue
        if (( size > bestsize )); then
            best="$path"
            bestsize="$size"
        fi
    done < <(lsblk -bnlo PATH,TYPE,FSTYPE,SIZE | awk '$2 == "part" { print $1, $3, $4 }')
    printf '%s' "$best"
}

suggest_swap_partition() {
    lsblk -nlo PATH,FSTYPE \
        | awk '$2 == "swap" { print $1; exit }'
}

is_partition() {
    [[ "$(lsblk -ndo TYPE "$1" 2>/dev/null)" == "part" ]]
}

is_block_device() {
    [[ -b "$1" ]]
}

# Source device of a mount, stripping the optional "[/subvol]" suffix that
# btrfs subvolume mounts carry (e.g. /dev/sda2[/@nix] -> /dev/sda2).
btrfs_dev_of() {
    findmnt -no SOURCE "$1" | sed 's/\[.*//'
}

uuid_of() {
    blkid -s UUID -o value "$1" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# Btrfs helpers.
#
# These deliberately do NOT parse text output of 'btrfs subvolume list'
# (its last column is a path that can contain spaces).  Instead the top-level
# volume (subvolid=5) is mounted once and subvolumes are detected by their
# inode: a btrfs subvolume root always has inode 256.
# ---------------------------------------------------------------------------

ensure_btrfs_top() {
    local dev
    mkdir -p "$BTRFS_TOP"
    if ! mountpoint -q "$BTRFS_TOP"; then
        dev="$(btrfs_dev_of "$TARGET")"
        [[ -n "$dev" ]] || die "could not determine Btrfs device from $TARGET."
        mount -t btrfs -o subvolid=5 "$dev" "$BTRFS_TOP"
    fi
}

release_btrfs_top() {
    umount "$BTRFS_TOP" 2>/dev/null || true
}

is_btrfs_subvolume() {
    [[ -d "$1" ]] || return 1
    [[ "$(stat -c '%i' "$1" 2>/dev/null || true)" == "256" ]]
}

btrfs_subvolume_exists() {
    ensure_btrfs_top
    is_btrfs_subvolume "$BTRFS_TOP/$1"
}

btrfs_subvolume_names() {
    ensure_btrfs_top
    local d
    for d in "$BTRFS_TOP"/*; do
        is_btrfs_subvolume "$d" || continue
        basename "$d"
    done
}

require_subvolume() {
    btrfs_subvolume_exists "$1" || die "missing Btrfs subvolume: $1"
}