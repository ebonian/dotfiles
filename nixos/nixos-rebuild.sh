#!/usr/bin/env bash

# A rebuild script using Nix flakes that commits on a successful build
set -e

# Navigate to your flake config directory
pushd ~/dotfiles/nixos/

# Early return if no changes were detected
if git diff --quiet .; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat your nix files
alejandra . &>/dev/null \
  || ( alejandra . ; echo "Formatting failed!" && exit 1)

# Add all changes
git add .

# Show your changes
# git diff -U0 '*.nix' '*.flake' '*.toml'

echo "NixOS Rebuilding with flakes..."

# Rebuild using flakes, show full output, and log tracebacks
sudo nixos-rebuild switch --flake ~/dotfiles/nixos# | tee nixos-switch.log \
  || (echo "Error during rebuild, see details below:" && cat nixos-switch.log && exit 1)

# Get current generation number
generation=$(nixos-rebuild list-generations | grep current | awk '{print $1}')

# Prompt the user for a commit message
read -p "Enter a commit message: " user_message

# Commit all changes with the generation number and user message
git commit -m "$generation $user_message"

# Back to where you were
popd

# Notify all OK!
notify-send -e "Rebuilt NixOS successfully!"
