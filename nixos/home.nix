{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules/zoxide.nix

    ./home/hyprland
  ];

  home.username = "ebonian";
  home.homeDirectory = "/home/ebonian";

  home.packages = with pkgs;
  let
    unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
  in
  [
    zip
    unzip
    fastfetch

    unstable.cargo
    unstable.rustc
    unstable.rust-analyzer

    kitty

    vscodium-fhs
    
    wofi
  ];

  programs.git = {
    enable = true;
    userName = "ebonian";
    userEmail = "tanadon.santisan@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
    ignores = [
      ".direnv"
      ".envrc"
    ];
  };

  programs.home-manager.enable = true;
  programs.direnv.enable = true;

  programs.bash.sessionVariables = {
    EDITOR = "nvim";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };


  home.stateVersion = "24.05";
}