{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    tofi
  ];

  home.file.".config/tofi" = {
    source = ./tofi;
    recursive = true;
  };
}
