#!/usr/bin/env bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

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

# Use tofi to select a wallpaper
SELECTED_NAME=$(printf '%s\n' "${WALL_NAMES[@]}" | tofi)

# Exit if no selection was made
if [ -z "$SELECTED_NAME" ]; then
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

# Preload wallpaper
hyprctl hyprpaper preload "$SELECTED_WALL"

# Get all monitor names
mapfile -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')

# Apply wallpaper to each monitor
for MON in "${MONITORS[@]}"; do
    hyprctl hyprpaper wallpaper "$MON,$SELECTED_WALL"
done

# Save selected wallpaper path for persistence
WALLPAPER_CACHE="$HOME/.cache/hyprpaper_current_wallpaper"
echo "$SELECTED_WALL" > "$WALLPAPER_CACHE"

notify-send "Wallpaper" "Set to $(basename "$SELECTED_WALL")"
