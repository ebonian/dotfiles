{
  inputs,
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  # programs.kitty.enable = true; # required for the default Hyprland config

  # Symlink individual config files, but NOT monitors.conf/workspaces.conf
  # so that nwg-displays can write to them
  home.file = {
    ".config/hypr/hyprland.conf".source = ./hyprland/hyprland.conf;
    ".config/hypr/hyprpaper.conf".source = ./hyprland/hyprpaper.conf;
    ".config/hypr/configs/appearance.conf".source = ./hyprland/configs/appearance.conf;
    ".config/hypr/configs/env.conf".source = ./hyprland/configs/env.conf;
    ".config/hypr/configs/exec.conf".source = ./hyprland/configs/exec.conf;
    ".config/hypr/configs/input.conf".source = ./hyprland/configs/input.conf;
    ".config/hypr/configs/keybinds.conf".source = ./hyprland/configs/keybinds.conf;
    ".config/hypr/scripts".source = ./hyprland/scripts;
    ".config/hypr/wallpapers".source = ./hyprland/wallpapers;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 14;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita-dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  home.packages = with pkgs; [
    hyprpaper
    hyprsunset
  ];
}
