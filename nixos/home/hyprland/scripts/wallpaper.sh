#!/usr/bin/env bash

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/.config/hypr/wallpapers"

# File to store the index of the last used wallpaper
INDEX_FILE="$HOME/.cache/hyprpaper_wall_index"

# Get all image files in the directory (case-insensitive match)
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -maxdepth 1 \( -type f -o -type l \) \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) | sort)

# Exit if no wallpapers
if [ ${#WALLS[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Read last index (default to 0 if file not found or invalid)
if [[ -f "$INDEX_FILE" ]] && [[ "$(cat "$INDEX_FILE")" =~ ^[0-9]+$ ]]; then
    INDEX=$(<"$INDEX_FILE")
else
    INDEX=0
fi

# Increment index and wrap around
INDEX=$(( (INDEX + 1) % ${#WALLS[@]} ))

# Save new index
echo "$INDEX" > "$INDEX_FILE"

# Selected wallpaper
WALL="${WALLS[$INDEX]}"

# Preload wallpaper
hyprctl hyprpaper preload "$WALL"

# Get all monitor names
mapfile -t MONITORS < <(hyprctl monitors -j | jq -r '.[].name')

# Apply wallpaper to each monitor
for MON in "${MONITORS[@]}"; do
    hyprctl hyprpaper wallpaper "$MON,$WALL"
done
