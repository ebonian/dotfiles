#!/usr/bin/env bash

# Function to list generations
list_generations() {
    echo "Listing generations..."
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
}

# Function to collect garbage
collect_garbage() {
    echo "Collecting garbage..."
    sudo nix-collect-garbage -d
    echo "Cleaning boot configuration..."
    sudo /run/current-system/bin/switch-to-configuration boot
}

# Function to remove specific generations
remove_generations() {
    echo "Please enter the generation numbers to remove, separated by spaces (e.g., 1 3 4 5 10):"
    read -r generations_to_remove

    if [[ -z "$generations_to_remove" ]]; then
        echo "No input provided. Exiting."
        exit 0
    fi

    echo "Removing generations: $generations_to_remove"
    sudo nix-collect-garbage --delete-generations $generations_to_remove
}

# Main script
if [[ "$1" == "--all" ]]; then
    echo "Removing all generations..."
    sudo nix-collect-garbage --delete-old
else
    list_generations
    remove_generations
fi

# Always collect garbage afterward
collect_garbage

echo "NixOS generations cleaned."