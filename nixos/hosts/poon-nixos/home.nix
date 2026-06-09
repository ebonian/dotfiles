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
    ../../home/vscodium.nix
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
    dev = import inputs.nixpkgs-dev {
      system = pkgs.system;
      config.allowUnfree = true;
    };
    claude = import inputs.nixpkgs-claude {
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
    claude.claude-code
    dev.code-cursor.fhs
    dev.antigravity-fhs
    dev.pencil
    dev.dbeaver-bin
    dev.zed-editor-fhs
    dev.arduino-ide
    dev.bruno
    dev.devtoolbox
    dev.bun
    dev.gh
    unstable.mongodb-compass
    unstable.trayscale
    unstable.cutecom
    unstable.lazyssh
    unstable.legcord
    telegram-desktop
    productivity.obsidian
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
    unstable.jdk25

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
    unstable.postgresql_18
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
      "--disable-features=WebRtcAllowInputVolumeAdjustment,EvictionThrottlesDraw"
      # "--ozone-platform=x11"
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

  home.file.".local/share/jvm/jdk25".source = "${(import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  }).jdk25}";

  home.activation.prismLauncherJavaDefault = config.lib.dag.entryAfter ["writeBoundary"] ''
    cfg="$HOME/.local/share/PrismLauncher/prismlauncher.cfg"
    java_path="$HOME/.local/share/jvm/jdk25/bin/java"
    if [ -f "$cfg" ] && [ -x "$java_path" ]; then
      run ${pkgs.gnused}/bin/sed -i \
        -e "s|^JavaPath=.*|JavaPath=$java_path|" \
        -e "s|^JavaVersion=.*|JavaVersion=25.0.2|" \
        -e "s|^JavaVendor=.*|JavaVendor=Oracle Corporation|" \
        -e "s|^JavaSignature=.*|JavaSignature=|" \
        -e "s|^AutomaticJavaSwitch=.*|AutomaticJavaSwitch=false|" \
        "$cfg"
    fi
    for inst in "$HOME/.local/share/PrismLauncher/instances"/*/instance.cfg; do
      [ -f "$inst" ] || continue
      if ${pkgs.gnugrep}/bin/grep -qE '^JavaVersion=1\.8\.' "$inst" 2>/dev/null; then
        run ${pkgs.gnused}/bin/sed -i \
          -e 's|^OverrideJavaLocation=.*|OverrideJavaLocation=false|' \
          -e '/^JavaPath=/d' \
          -e '/^JavaVersion=/d' \
          -e '/^JavaVendor=/d' \
          -e '/^JavaSignature=/d' \
          -e '/^JavaArchitecture=/d' \
          -e '/^JavaRealArchitecture=/d' \
          "$inst"
      fi
    done
  '';

  home.stateVersion = "25.05";
}
