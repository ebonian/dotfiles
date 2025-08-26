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
    extraGroups = ["networkmanager" "wheel" "docker" "plugdev"];
    initialPassword = "password";
  };
  users.extraUsers.poon.extraGroups = ["audio"];

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
    theme = "catppuccin-mocha";
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

  # Enable asusctl
  services.power-profiles-daemon.enable = true;
  systemd.services.power-profiles-daemon = {
    enable = true;
    wantedBy = ["multi-user.target"];
  };
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [pkgs.pciutils];

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
}
