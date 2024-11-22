{pkgs, ...}: {
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

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      fira
      ibm-plex
      jetbrains-mono
      fira-code-symbols
      powerline-fonts
      nerdfonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = ["Noto Sans Thai Looped"];
        sansSerif = ["Noto Sans Thai Looped"];
        monospace = ["Noto Sans Thai Looped"];
      };
    };

    fontDir.enable = true;
  };

  # Nix
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.substituters = ["https://cache.nixos.org" "https://ros.cachix.org"];
  nix.settings.trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ebonian = {
    isNormalUser = true;
    description = "Tanadon Santisan";
    extraGroups = ["networkmanager" "wheel" "docker" "plugdev"];
    initialPassword = "password";
  };

  # Drive Mounting
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  services.displayManager.sddm = {
    enable = true;
  };

  services.xserver.enable = true;

  #  Configure keymap in X11
  services.xserver.xkb = {
    layout = "us,th";
    variant = ",";
    options = "grp:caps_toggle";
  };
}
