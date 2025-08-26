{ inputs, pkgs, ...}:

{
  programs.waybar.enable = true;

  home.file.".config/waybar" = {
    source = ./waybar;
    recursive = true;
  };

  home.packages = with pkgs; [
    pavucontrol
  ];
}
