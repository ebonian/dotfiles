{
  config,
  pkgs,
  nixpkgs-unstable,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/docker.nix
    ../../modules/firefox.nix
    ../../modules/hyprland.nix
    ../../modules/system.nix
    ../../modules/zsh.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nlap"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable asusctl
  services.asusd = {
    enable = true;
    enableUserService = true;
  };
  services.supergfxd.enable = true;
  systemd.services.supergfxd.path = [pkgs.pciutils];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.upower.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; let
    unstable = nixpkgs-unstable.legacyPackages.${pkgs.system};
  in [
    git

    vim
    wget
    firefox

    alejandra

    gcc
    patchelf
    pkg-config
    openssl

    dconf

    asusctl
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    # pinentryPackage = "curses";
    # enableSSHSupport = true;
  };

  # Enable SSH Agent
  programs.ssh.startAgent = true;

  # Enviroments
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  system.stateVersion = "24.05";
}
