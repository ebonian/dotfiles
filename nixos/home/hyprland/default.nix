{ inputs, pkgs, nixpkgs-unstable, lib, ... }:

{
  home.file.".config/hypr/hyprland.conf" = {
    source = ./hyprland.conf;
    recursive = true;
  };

  home.file.".config/hypr/configs" = {
    source = ./configs;
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
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
