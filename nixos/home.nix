{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./modules/zoxide.nix

    ./home/fastfetch
    ./home/firefox
    ./home/hyprland
    ./home/kitty
    ./home/rofi
  ];

  home.username = "ebonian";
  home.homeDirectory = "/home/ebonian";

  home.packages = with pkgs; let
    unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
  in [
    unstable.neovim

    zip
    unzip

    unstable.cargo
    unstable.rustc
    unstable.rust-analyzer

    vscodium-fhs

    libnotify
  ];

  programs.git = {
    enable = true;
    userName = "ebonian";
    userEmail = "52095091+ebonian@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      url = {
        "ssh://git@github.com" = {
          insteadOf = "https://github.com";
        };
      };
      user.signingkey = "7DB0F3FF9D4A2470";
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
