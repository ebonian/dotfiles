#!/usr/bin/env bash

# Focus Obsidian if running, otherwise launch it

if hyprctl clients -j | jq -e '.[] | select(.class == "obsidian")' > /dev/null 2>&1; then
    hyprctl dispatch focuswindow class:obsidian
else
    obsidian &
fi
