{
  inputs,
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  # programs.kitty.enable = true; # required for the default Hyprland config

  home.file.".config/hypr" = {
    source = ./hyprland;
    recursive = true;
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
  ];
}
