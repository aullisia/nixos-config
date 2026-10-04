#!/usr/bin/env bash
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cfg="$dir/package.nix"
wbfr="$dir/wbfreerdp.nix"
guest="$dir/guest-server.nix"

echo "== WinBoat update helper =="
echo "Working dir: $dir"
echo

branch="1.0-bleeding-edge"

echo "=== 1) App (winboat-org/winboat, $branch) ==="
app_sha=$(gh api repos/winboat-org/winboat/commits/$branch -q .sha)
pkgjson_raw=$(gh api repos/winboat-org/winboat/contents/package.json?ref=$branch -q .content | base64 -d)
app_ver=$(echo "$pkgjson_raw" | jq -r .version)
echo "Latest commit SHA: $app_sha"
echo "package.json version: $app_ver"
app_hash=$(nix-prefetch-github winboat-org winboat --rev "$app_sha" 2>/dev/null | jq -r .hash)
echo "src.hash (nix-prefetch-github): $app_hash"
echo
echo "To apply:"
echo "  - pkgs/winboat/package.nix: rev = \"$app_sha\" (line ~55)"
echo "  - pkgs/winboat/package.nix: version = \"${app_ver}-unstable-$(date +%Y-%m-%d)\" (line ~53)"
echo "  - pkgs/winboat/package.nix: hash  = \"$app_hash\" (line ~57)"
echo

echo "=== 2) npmDepsHash (if deps changed) ==="
echo "If dependencies changed, regenerate package-lock.json from upstream and get new npmDepsHash:"
cat <<'TXT'
  git clone -b 1.0-bleeding-edge https://github.com/winboat-org/winboat /tmp/winboat-up
  cd /tmp/winboat-up
  jq 'del(.patchedDependencies)' package.json > t && mv t package.json
  npm install --package-lock-only --ignore-scripts
  cp package-lock.json ~/nixos-config/pkgs/winboat/
  nix build .#winboat 2>&1 | grep -B1 -A30 'npmDepsHash'
TXT
echo

echo "=== 3) FreeRDP fork (WBFreeRDP) ==="
fr_sha=$(gh api repos/winboat-org/WBFreeRDP/commits --jq '.[0].sha')
fr_hash=$(nix-prefetch-github winboat-org WBFreeRDP --rev "$fr_sha" 2>/dev/null | jq -r .hash)
echo "Latest commit: $fr_sha"
echo "src.hash: $fr_hash"
echo
echo "To apply (wbfreerdp.nix:20,34):"
echo "  rev  = \"$fr_sha\""
echo "  hash = \"$fr_hash\""
echo

echo "=== 4) Guest server Go vendorHash ==="
echo "After updating app src (and possibly go.mod), vendorHash is determined on build:"
echo "  nix build .#winboat-guest-server 2>&1 | grep -B2 -A5 'vendorHash'"
echo "  then edit pkgs/winboat/guest-server.nix:24"

echo
echo "=== 5) Helios GPU bundle (expires ~90d) ==="
echo "Check for new run/artifact if needed; see cheat-sheet. Current flake points to:"
grep -n 'helios-bundle' /home/aul/nixos-config/modules/flake-inputs.nix
echo

echo "=== Build order ==="
echo "nix build .#wbfreerdp && nix build .#winboat-guest-server && nix build .#winboat"
echo "./rebuild.sh"
