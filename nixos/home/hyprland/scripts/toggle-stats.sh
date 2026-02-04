#!/usr/bin/env bash

# Toggle waybar stats (cpu, memory, temperature) visibility
# Uses two configs: full (with stats) and minimal (without stats)

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-stats-hidden"
CONFIG_DIR="$HOME/.config/waybar"

pkill waybar

if [ -f "$STATE_FILE" ]; then
    # Stats are hidden, show them (use full config)
    rm "$STATE_FILE"
    waybar &
else
    # Stats are visible, hide them (use minimal config)
    touch "$STATE_FILE"
    waybar -c "$CONFIG_DIR/config-minimal.jsonc" &
fi
