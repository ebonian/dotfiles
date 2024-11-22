{
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    version = "0.10.0";
  };
}
