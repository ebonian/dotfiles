#!/usr/bin/env bash

# Toggle the expanded stats view (super+i).
#   Resting state (default on login) -> config.jsonc:
#     workspaces + volume, battery, clock (icon-only).
#   Expanded state                   -> config-full.jsonc:
#     all icons (cpu, memory, temperature, volume, battery) with the value
#     on a second line under each icon.

STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-stats-shown"
CONFIG_DIR="$HOME/.config/waybar"

pkill waybar

if [ -f "$STATE_FILE" ]; then
    # Expanded is showing -> go back to the minimal resting view
    rm "$STATE_FILE"
    waybar &
else
    # Minimal is showing -> expand to the full stats view
    touch "$STATE_FILE"
    waybar -c "$CONFIG_DIR/config-full.jsonc" &
fi
