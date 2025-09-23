#!/usr/bin/env bash
set -euo pipefail

# Usage: autostart-runner.sh [DIR] [LOGFILE]
DIR="${1:-$HOME/.config/autostart-scripts}"
LOG="${2:-$HOME/.cache/autostart-runner.log}"
# LOCK="/tmp/autostart-runner.lock"

mkdir -p "$DIR"
mkdir -p "$(dirname "$LOG")"

# exec 9>"$LOCK"
# if ! flock -n 9; then
#   echo "$(date --iso-8601=seconds) - another instance is running, exiting" >>"$LOG"
#   exit 0
# fi

echo "$(date --iso-8601=seconds) - autostart-runner starting, scanning: $DIR" >>"$LOG"

mapfile -d '' files < <(find "$DIR" -maxdepth 2 -type f -print0 | sort -z)

for f in "${files[@]}"; do
  [[ -z "$f" ]] && continue

  is_sh=false
  if [[ "$f" == *.sh ]]; then
    is_sh=true
  elif [ -x "$f" ]; then
    is_sh=true
  else
    head_line="$(head -n 1 -- "$f" 2>/dev/null || true)"
    if [[ "$head_line" =~ ^#! ]]; then
      is_sh=true
    fi
  fi

  if [ "$is_sh" = true ]; then
    echo "$(date --iso-8601=seconds) - running: $f" >>"$LOG"
    nohup bash "$f" >>"$LOG" 2>&1 &
    sleep 0.05
  else
    echo "$(date --iso-8601=seconds) - skipping (not a shell script): $f" >>"$LOG"
  fi
done

echo "$(date --iso-8601=seconds) - autostart-runner finished scan." >>"$LOG"
exit 0
