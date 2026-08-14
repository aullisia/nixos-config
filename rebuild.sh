#!/usr/bin/env bash
set -euo pipefail

flake_dir="$(dirname "$(realpath "$0")")"
host="${1:-$(hostname)}"

echo "Rebuilding NixOS for host: $host"

sudo nixos-rebuild switch --flake "$flake_dir#$host" "$@" 2>&1
