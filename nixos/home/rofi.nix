{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    rofi
  ];

  home.file.".config/rofi" = {
    source = ./rofi;
    recursive = true;
  };
}
