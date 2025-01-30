{
  inputs,
  pkgs,
  ...
}: {
  home.file.".config/ghostty" = {
    source = ./ghostty;
    recursive = true;
  };

  home.packages = [
    inputs.ghostty.packages.${pkgs.system}.default
  ];
}
