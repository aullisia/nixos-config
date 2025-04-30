#!/usr/bin/env bash

MIC=$(pactl info | awk -F': ' '/Default Source/ {print $2}')
MUTED=$(pactl get-source-mute "$MIC" | awk '{print $2}')

if [ "$MUTED" = "yes" ]; then
  pactl set-source-mute "$MIC" 0
  NEW_MUTED="no"
else
  pactl set-source-mute "$MIC" 1
  NEW_MUTED="yes"
fi

if [ "$NEW_MUTED" = "yes" ]; then
  ICON="󰍭"
  CLASS="muted"
else
  ICON=""
  CLASS="unmuted"
fi

printf '{"text":"[ %s ]","class":"%s"}\n' "$ICON" "$CLASS"
