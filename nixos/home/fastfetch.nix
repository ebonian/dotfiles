{
  inputs,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fastfetch
  ];

  home.file.".config/fastfetch" = {
    source = ./fastfetch;
    recursive = true;
  };
}
