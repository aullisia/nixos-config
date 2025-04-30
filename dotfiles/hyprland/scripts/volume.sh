#!/usr/bin/env bash

toggle_mute() {
  SINK=$(pactl get-default-sink)
  pactl set-sink-mute "$SINK" toggle
}

if [ "$1" == "toggle" ]; then
  toggle_mute
  exit 0
fi

SINK=$(pactl get-default-sink)

VOLUME=$(pactl get-sink-volume "$SINK" | awk -F'/' '/Volume:/ {print $2}' | head -n1 | tr -d ' %')

MUTED=$(pactl get-sink-mute "$SINK" | awk '{print $2}')

if [ "$MUTED" = "yes" ]; then
  ICON=""
  CLASS="muted"
else
  ICON=""
  CLASS="unmuted"
fi

FILLED=$((VOLUME / 10))
EMPTY=$((10 - FILLED))
BAR=""
for ((i=0; i<FILLED; i++)); do
  BAR+="\u2588"
done
for ((i=0; i<EMPTY; i++)); do
  BAR+="\u2591"
done

printf '{"text":"%s [%s]%s%%","class":"%s","percentage":%d}\n' "$ICON" "$BAR" "$VOLUME" "$CLASS" "$VOLUME"
