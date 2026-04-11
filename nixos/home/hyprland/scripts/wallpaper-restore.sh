#!/usr/bin/env bash

# File to store the current wallpaper path
WALLPAPER_CACHE="$HOME/.cache/hyprpaper_current_wallpaper"

# Check if a saved wallpaper exists
if [ ! -f "$WALLPAPER_CACHE" ]; then
    # No saved wallpaper, exit silently
    exit 0
fi

# Read the saved wallpaper path
SELECTED_WALL=$(cat "$WALLPAPER_CACHE")

# Check if the wallpaper file still exists
if [ ! -f "$SELECTED_WALL" ]; then
    # Wallpaper file no longer exists, remove cache
    rm -f "$WALLPAPER_CACHE"
    exit 0
fi

# Wait a bit for hyprpaper to be ready
sleep 0.5

# Get all monitor names
mapfile -t MONITORS < <(hyprctl monitors -j 2>/dev/null | jq -r '.[].name' 2>/dev/null)

# Apply wallpaper to each monitor (preloading is automatic in hyprpaper 0.8+)
for MON in "${MONITORS[@]}"; do
    hyprctl hyprpaper wallpaper "$MON,$SELECTED_WALL" 2>/dev/null || exit 0
done

