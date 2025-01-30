{pkgs, ...}: {
  home.file.".config/wofi" = {
    source = ./wofi;
    recursive = true;
  };

  home.packages = with pkgs; [
    wofi
  ];
}
