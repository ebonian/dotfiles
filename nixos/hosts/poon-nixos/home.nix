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
    ../../home/eww.nix
    ../../home/fastfetch.nix
    ../../home/ghostty.nix
    ../../home/tmux.nix
    ../../home/tofi.nix
  ];

  # Enable home manager
  programs.home-manager.enable = true;

  home.username = "poon";
  home.homeDirectory = "/home/poon";

  home.packages = with pkgs; let
    unstable = import inputs.nixpkgs-unstable {
      system = pkgs.system;
      config.allowUnfree = true;
    };
    cursor = import inputs.nixpkgs-cursor {
      system = pkgs.system;
      config.allowUnfree = true;
    };
    brave = import inputs.nixpkgs-brave {
      system = pkgs.system;
      config.allowUnfree = true;
    };
    antigravity = import inputs.nixpkgs-antigravity {
      system = pkgs.system;
      config.allowUnfree = true;
    };
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
    nodejs_22

    # programs
    wofi
    neovim
    vscodium-fhs
    cursor.code-cursor.fhs
    unstable.discord
    spotify
    bitwarden-desktop
    dbeaver-bin
    bruno
    google-cloud-sdk
    google-cloud-sql-proxy
    obs-studio
    xfce.thunar
    xfce.ristretto
    xfce.tumbler
    xfce.mousepad
    galculator
    vlc
    devtoolbox
    libreoffice-qt6-fresh
    postman
    mongodb-compass
    helvum
    realvnc-vnc-viewer
    firebase-tools
    unstable.zed-editor-fhs
    antigravity.antigravity-fhs

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
    btop
    postgresql
    meow
    bat
    cloudflared
    ttyper
    ffmpeg
    nmap
    v4l-utils
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
    package =
      (import inputs.nixpkgs-brave {
        system = pkgs.system;
        config.allowUnfree = true;
      }).brave;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # ublock origin
      {id = "nngceckbapebfimnlniiiahkandclblb";} # bitwarden
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
      # Use persistent profile directory to preserve sessions/cookies across updates
      "--user-data-dir=${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser"
    ];
  };

  # Setup editor variable
  programs.bash.sessionVariables = {
    EDITOR = "nvim";
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    # Ensure tofi and other launchers can find desktop entries from home-manager
    XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
  };

  home.stateVersion = "25.05";
}
