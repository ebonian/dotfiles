{pkgs, ...}: {
  home.file.".config/eww" = {
    source = ./eww;
    recursive = true;
  };

  home.packages = with pkgs; [
    eww
  ];
}
