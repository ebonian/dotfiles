{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./modules/fastfetch.nix
    ./modules/zoxide.nix

    ./home/dunst.nix
    ./home/eww.nix
    ./home/firefox.nix
    ./home/ghostty.nix
    ./home/hyprland.nix
    ./home/kitty.nix
    ./home/zsh.nix
  ];

  # Enable home manager
  programs.home-manager.enable = true;

  home.username = "ebonian";
  home.homeDirectory = "/home/ebonian";

  # Home profile packages
  home.packages = with pkgs; let
    unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.system};
  in [
    # languages
    unstable.cargo
    unstable.rustc
    unstable.rust-analyzer
    (pkgs.python3.withPackages (python-pkgs:
      with python-pkgs; [
        pandas
        numpy
        requests
      ]))
    lua

    # programs
    unstable.neovim
    vscodium-fhs
    wofi

    # utilities
    brightnessctl
    networkmanagerapplet
    libnotify
    grim
    slurp
    swappy
    eza
    yq
    ripgrep
    obs-studio
    arandr
  ];

  # Git configurations
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

  # Enable direnv
  programs.direnv.enable = true;

  # Setup editor variable
  programs.bash.sessionVariables = {
    EDITOR = "nvim";
  };
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "24.05";
}
