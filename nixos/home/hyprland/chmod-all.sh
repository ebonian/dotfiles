#!/usr/bin/env bash

# Change directory to the scripts folder
cd ./scripts || { echo "Directory ./scripts not found!"; exit 1; }

# Find all .sh files and apply chmod +x
for file in *.sh; do
  if [ -f "$file" ]; then
    chmod +x "$file"
    echo "Added execute permission to $file"
  fi
done

echo "All .sh files in ./scripts have been updated."
