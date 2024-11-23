{
  config,
  pkgs,
  nixpkgs-unstable,
  ...
}: let
  g14_patches = fetchGit {
    url = "https://gitlab.com/dragonn/linux-g14";
    ref = "6.11";
    rev = "c75ff27d0e3a7faf7f50c04a8a23014909e70980";
  };
in {
  imports = [
    ./hardware-configuration.nix

    ../../modules/docker.nix
    ../../modules/firefox.nix
    ../../modules/hyprland.nix
    ../../modules/system.nix
    ../../modules/zsh.nix
  ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Boot kernel
  boot.kernelPackages = pkgs.linuxPackages_6_11;
  boot.kernelPatches = map (patch: {inherit patch;}) [
    "${g14_patches}/0001-Bluetooth-btusb-Add-2-USB-HW-IDs-for-MT7925-0xe118-e.patch"
    "${g14_patches}/0032-Bluetooth-btusb-Add-a-new-PID-VID-0489-e0f6-for-MT7922.patch"
    "${g14_patches}/0062-hid-asus-use-hid-for-brightness-control-on-keyboard.patch"
    "${g14_patches}/sys-kernel_arch-sources-g14_files-0004-more-uarches-for-kernel-6.8-rc4+.patch"
    "${g14_patches}/sys-kernel_arch-sources-g14_files-0047-asus-nb-wmi-Add-tablet_mode_sw-lid-flip.patch"
    "${g14_patches}/sys-kernel_arch-sources-g14_files-0048-asus-nb-wmi-fix-tablet_mode_sw_int.patch"
  ];

  # Networking
  networking.hostName = "nlap"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
