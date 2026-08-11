{pkgs, ...}: {
  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.substituters = ["https://cache.nixos.org" "https://ros.cachix.org"];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  fonts = {
    packages = with pkgs; [
      # Standard Xorg fonts for VNC Viewer
      xorg.fontadobe100dpi
      xorg.fontadobe75dpi
      xorg.fontbh100dpi
      xorg.fontbh75dpi
      xorg.fontmiscmisc

      dejavu_fonts

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      fira-code
      fira
      ibm-plex
      jetbrains-mono
      fira-code-symbols
      powerline-fonts
      pkgs.nerd-fonts.caskaydia-cove
    ];

    fontconfig = {
      defaultFonts = {
        serif = ["Noto Sans Thai"];
        sansSerif = ["Noto Sans Thai"];
        monospace = ["CaskaydiaCove Nerd Font"];
      };
    };

    fontDir.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.poon = {
    isNormalUser = true;
    description = "Poon";
    extraGroups = ["networkmanager" "wheel" "docker" "plugdev" "dialout"];
    initialPassword = "password";
  };
  users.extraUsers.poon.extraGroups = ["audio"];

  # Allow passwordless battery charge limit toggle
  security.sudo.extraRules = [
    {
      users = ["poon"];
      commands = [
        {
          command = "${pkgs.polkit}/bin/pkexec";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # SDDM Theme
  environment.systemPackages = [
    (
      pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        font = "Noto Sans";
        fontSize = "9";
      }
    )
  ];

  # Enable SDDM
  services.displayManager.sddm = {
    enable = true;
    theme = "where_is_my_sddm_theme";
    package = pkgs.kdePackages.sddm;
  };

  # Drive Mounting
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Enable xserver
  services.xserver.enable = true;

  #  Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,th";
    variant = ",";
    options = "grp:alt_shift_toggle";
  };

  # Power Management
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_SCALING_MIN_FREQ_ON_AC = 400000;
      CPU_SCALING_MAX_FREQ_ON_AC = 5263000;
      CPU_SCALING_MIN_FREQ_ON_BAT = 400000;
      CPU_SCALING_MAX_FREQ_ON_BAT = 1800000; # Cap at 1.8GHz on battery to save power

      # Auto-switch ASUS platform profile by power source (caps package TDP).
      # NOTE: asusd also manages platform_profile; TLP re-asserts these on every
      # AC<->battery transition, so a manual `asusctl profile -P` holds only until
      # the next power event. If they ever fight, drop these two lines.
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "quiet";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      # Battery charge thresholds managed by asusd (asusctl -c)
      # TLP's tlp-sleep.service overwrites the threshold on every
      # resume, conflicting with the user's runtime choice.
    };
  };

  # Enable asusctl
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [pkgs.pciutils];

  # Ensure asusd starts on boot (fix missing WantedBy)
  systemd.services.asusd.wantedBy = ["multi-user.target"];

  # Battery Optimization
  powerManagement.powertop.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.upower.enable = true;

  # Enable sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true; # if not already enabled
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment the following
    #jack.enable = true;
  };

  # Qt
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}
