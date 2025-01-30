{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    inputs.ghostty.packages.${pkgs.system}.default
  ];

  xdg.configFile."ghostty/config".text = ''
    ${builtins.readFile ./ghostty/config}
  '';
}
