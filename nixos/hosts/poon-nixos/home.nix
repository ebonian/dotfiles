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
    ide = import inputs.nixpkgs-ide {
      system = pkgs.system;
      config.allowUnfree = true;
    };
    brave = import inputs.nixpkgs-brave {
      system = pkgs.system;
      config.allowUnfree = true;
    };
    productivity = import inputs.nixpkgs-productivity {
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
    ide.claude-code
    ide.claude-code-acp
    ide.vscodium-fhs
    ide.code-cursor.fhs
    ide.antigravity-fhs
    ide.pencil
    ide.dbeaver-bin
    ide.zed-editor-fhs
    ide.arduino-ide
    ide.bruno
    ide.devtoolbox
    unstable.mongodb-compass
    unstable.trayscale
    unstable.cutecom
    unstable.lazyssh
    bitwarden-desktop
    google-cloud-sdk
    google-cloud-sql-proxy
    obs-studio
    xfce.thunar
    xfce.thunar-archive-plugin # Right-click archive/extract in Thunar
    xfce.ristretto
    xfce.tumbler
    xfce.mousepad
    xarchiver # Archive manager GUI
    zip
    unzip
    p7zip # 7z support
    unrar # RAR support
    galculator
    vlc
    libreoffice-qt6-fresh
    helvum
    realvnc-vnc-viewer
    firebase-tools
    prismlauncher

    # utilities
    overskride
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
    wlr-randr # Wayland replacement for xrandr
    nwg-displays # GUI for Wayland display management (like arandr)
    btop
    postgresql
    meow
    bat
    cloudflared
    ttyper
    ffmpeg
    nmap
    v4l-utils
    wl-clipboard
    dcfldd
  ];

  # SSH configurations
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
  };

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

  home.file.".gnupg/gpg-agent.conf".text = ''
    default-cache-ttl-ssh 34560000
    max-cache-ttl-ssh 34560000
  '';

  home.stateVersion = "25.05";
}
