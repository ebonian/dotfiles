{pkgs, ...}: {
  home.file.".config/rofi/config.rasi" = {
    source = ./config.rasi;
    recursive = true;
  };

  home.packages = with pkgs; [
    rofi
  ];
}
