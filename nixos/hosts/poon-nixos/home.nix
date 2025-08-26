{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../home/firefox.nix
    ../../home/dunst.nix
    ../../home/hyprland.nix
    ../../home/waybar.nix
    ../../home/zsh.nix
    ../../home/rofi.nix
    ../../home/eww.nix
  ];

  # Enable home manager
  programs.home-manager.enable = true;

  home.username = "poon";
  home.homeDirectory = "/home/poon";

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
    fastfetch
    xfce.thunar
    neovim
    vscodium-fhs
    code-cursor
    discord
    spotify
    bitwarden-desktop
    dbeaver-bin
    bruno
    google-cloud-sdk
    google-cloud-sql-proxy

    # utilities
    brightnessctl
    networkmanagerapplet
    libnotify
    grim
    slurp
    swappy
    eza
    yq
    jq
    ripgrep
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
    };
    ignores = [
      ".direnv"
      ".envrc"
    ];
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };

  # Setup editor variable
  programs.bash.sessionVariables = {
    EDITOR = "nvim";
  };
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.stateVersion = "25.05";
}
