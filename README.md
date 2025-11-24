# NixOS Dotfiles

Personal NixOS configuration with Hyprland, managed using flakes and home-manager.

## System Overview

- **Host**: poon-nixos
- **WM**: Hyprland
- **Shell**: zsh with various configurations
- **Editor**: Neovim, Cursor (FHS-wrapped)

## Quick Start

### Build and Switch

```bash
# Rebuild system configuration
sudo nixos-rebuild switch --flake .#poon-nixos
```

### Update Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input only
nix flake lock --update-input <input-name>
```

## Updating Specific Packages Independently

Sometimes you want to update a single package without updating everything else. This is useful for applications like Cursor that you want to keep up-to-date independently from your other packages.

### How It Works

By creating a separate flake input for a specific package, you can update it independently. Here's how it's set up for Cursor:

**1. In `flake.nix`, add a separate input:**

```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  nixpkgs-cursor.url = "github:nixos/nixpkgs/nixos-unstable";  # Separate input for cursor
  # ...
};
```

**2. Add it to outputs:**

```nix
outputs = {
  self,
  nixpkgs,
  nixpkgs-unstable,
  nixpkgs-cursor,  # Add here
  home-manager,
  ...
} @ inputs: {
  # ...
};
```

**3. In `home.nix`, create a separate package set:**

```nix
home.packages = with pkgs; let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  cursor = import inputs.nixpkgs-cursor {  # Separate package set
    system = pkgs.system;
    config.allowUnfree = true;
  };
in [
  cursor.code-cursor.fhs  # Use from cursor package set
  unstable.cargo          # Other packages from unstable
  # ...
];
```

### Update Cursor Only

```bash
# Update cursor to latest version
nix flake lock --update-input nixpkgs-cursor

# Apply changes
sudo nixos-rebuild switch --flake .#poon-nixos
```

### Update Other Unstable Packages (Without Cursor)

```bash
# Update unstable packages (cargo, rust, etc.) but not cursor
nix flake lock --update-input nixpkgs-unstable

# Apply changes
sudo nixos-rebuild switch --flake .#poon-nixos
```

### Creating a Channel for Any Package

You can apply this pattern to any package:

1. Add a new input in `flake.nix`: `nixpkgs-<package>.url = "github:nixos/nixpkgs/nixos-unstable"`
2. Add it to outputs parameters
3. Create a package set in `home.nix`
4. Use `<package-set>.<package-name>` in your package list
5. Update independently with `nix flake lock --update-input nixpkgs-<package>`

## Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependencies
└── nixos/
    ├── hosts/
    │   └── poon-nixos/
    │       ├── default.nix           # System configuration
    │       ├── home.nix              # Home-manager configuration
    │       └── hardware-configuration.nix
    ├── home/              # Home-manager modules
    │   ├── hyprland/
    │   ├── waybar/
    │   ├── zsh.nix
    │   └── ...
    └── modules/           # System modules
        ├── docker.nix
        ├── system.nix
        └── ...
```

## Notes

- Using FHS-wrapped applications (like `code-cursor.fhs`) provides better compatibility with extensions
- Always run `sudo nixos-rebuild switch` after updating flake inputs to apply changes
