{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ghostty
  ];

  home.file.".config/ghostty" = {
    source = ./ghostty;
    recursive = true;
  };
}
