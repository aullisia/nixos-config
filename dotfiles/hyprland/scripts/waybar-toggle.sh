#!/bin/sh

PID=$(pidof waybar)

if [ -n "$PID" ]; then
  kill "$PID"
else
  waybar &
fi
