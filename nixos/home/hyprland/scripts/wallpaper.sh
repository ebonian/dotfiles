#!/usr/bin/env bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
WALLPAPER_CACHE="$HOME/.cache/hyprpaper_current_wallpaper"

# Get all image files in the directory (case-insensitive match)
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -maxdepth 1 \( -type f -o -type l \) \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) | sort)

# Exit if no wallpapers
if [ ${#WALLS[@]} -eq 0 ]; then
    notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Extract just the filenames for tofi display
mapfile -t WALL_NAMES < <(printf '%s\n' "${WALLS[@]}" | xargs -n1 basename)

# Use tofi to select a wallpaper (with disable option)
SELECTED_NAME=$(printf '%s\n' "Disable Wallpaper" "${WALL_NAMES[@]}" | tofi)

# Exit if no selection was made
if [ -z "$SELECTED_NAME" ]; then
    exit 0
fi

# Handle disable wallpaper
if [ "$SELECTED_NAME" = "Disable Wallpaper" ]; then
    killall hyprpaper 2>/dev/null
    rm -f "$WALLPAPER_CACHE"
    notify-send "Wallpaper" "Wallpaper disabled"
    exit 0
fi

# Find the full path of the selected wallpaper
SELECTED_WALL=""
for WALL in "${WALLS[@]}"; do
    if [ "$(basename "$WALL")" = "$SELECTED_NAME" ]; then
        SELECTED_WALL="$WALL"
        break
    fi
done

# Exit if selected wallpaper not found
if [ -z "$SELECTED_WALL" ]; then
    notify-send "Wallpaper" "Selected wallpaper not found"
    exit 1
fi

# Read previous wallpaper for cleanup
OLD_WALL=""
if [ -f "$WALLPAPER_CACHE" ]; then
    OLD_WALL=$(cat "$WALLPAPER_CACHE")
fi

# Ensure hyprpaper is running (may have been killed by disable)
if ! pgrep -x hyprpaper > /dev/null; then
    hyprpaper &
    sleep 0.5
fi

# Get all monitor names
mapfile -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')

# Apply wallpaper to each monitor
for MON in "${MONITORS[@]}"; do
    hyprctl hyprpaper wallpaper "$MON,$SELECTED_WALL"
done

# Unload previous wallpaper to free memory
if [ -n "$OLD_WALL" ] && [ "$OLD_WALL" != "$SELECTED_WALL" ]; then
    hyprctl hyprpaper unload "$OLD_WALL"
fi

# Save selected wallpaper path for persistence
echo "$SELECTED_WALL" > "$WALLPAPER_CACHE"

notify-send "Wallpaper" "Set to $(basename "$SELECTED_WALL")"
