{
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  nixpkgs-unstable.neovim = {
    enable = true;
  };
}
