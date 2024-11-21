{ pkgs, nixpkgs-unstable, lib, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
}