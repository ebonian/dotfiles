{pkgs, ...}: {
  home.file.".config/kitty" = {
    source = ./kitty/kitty.conf;
    recursive = true;
  };

  home.packages = with pkgs; [
    kitty
  ];
}
