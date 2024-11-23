{pkgs, ...}: {
  home.file.".config/dunst" = {
    source = ./dunst;
    recursive = true;
  };

  home.packages = with pkgs; [
    dunst
  ];
}
