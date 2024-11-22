#!/usr/bin/env bash

# A rebuild script using Nix flakes that commits on a successful build
set -e

# Navigate to your flake config directory
pushd ~/dotfiles/nixos/

# Early return if no changes were detected
if git diff --quiet '*.nix' '*.flake' '*.toml'; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat your nix files
alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

# Show your changes
git diff -U0 '*.nix' '*.flake' '*.toml'

echo "NixOS Rebuilding with flakes..."

# Rebuild using flakes, output simplified errors, log tracebacks
sudo nixos-rebuild switch --flake ~/dotfiles/nixos# &>nixos-switch.log \
  || (cat nixos-switch.log | grep --color error && exit 1)

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes with the generation metadata
git commit -am "$current"

# Back to where you were
popd

# Notify all OK!
# notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
