{
  pkgs,
  nixpkgs-unstable,
  ...
}: let
  g14_patches = fetchGit {
    url = "https://gitlab.com/dragonn/linux-g14";
    ref = "6.14";
    rev = "c75ff27d0e3a7faf7f50c04a8a23014909e70980";
  };
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/system.nix
    ../../modules/docker.nix
    ../../modules/zsh.nix
    ../../modules/zoxide.nix
    ../../modules/performance.nix
    ../../modules/bluetooth.nix
    ../../modules/arduino.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_6_14;
  boot.kernelPatches = map (patch: {inherit patch;}) [
    "${g14_patches}/0001-acpi-proc-idle-skip-dummy-wait.patch"
    "${g14_patches}/0040-workaround_hardware_decoding_amdgpu.patch"
    "${g14_patches}/0070-acpi-x86-s2idle-Add-ability-to-configure-wakeup-by-A.patch"
    "${g14_patches}/sys-kernel_arch-sources-g14_files-0004-more-uarches-for-kernel-6.8-rc4+.patch"
    "${g14_patches}/sys-kernel_arch-sources-g14_files-0047-asus-nb-wmi-Add-tablet_mode_sw-lid-flip.patch"
    "${g14_patches}/sys-kernel_arch-sources-g14_files-0048-asus-nb-wmi-fix-tablet_mode_sw_int.patch"
    "${g14_patches}/v2-0002-hid-asus-change-the-report_id-used-for-HID-LED-co.patch"
  ];

  # Networking
  networking.hostName = "poon-nixos"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.nameservers = ["1.1.1.1"];
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8081 19000 19001 25565];
    allowedUDPPorts = [8081 19000 19001 25565];
    extraCommands = ''
      iptables -I INPUT 1 -s 172.16.0.0/12 -p tcp -d 172.17.0.1 -j ACCEPT
      iptables -I INPUT 2 -s 172.16.0.0/12 -p udp -d 172.17.0.1 -j ACCEPT
    '';
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; let
    unstable = nixpkgs-unstable.legacyPackages.${pkgs.system};
  in [
    linuxKernel.packages.linux_6_15.cpupower

    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    nixd
    nil
    alejandra
    kitty
    gcc
    file
    killall

    where-is-my-sddm-theme
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
  programs.hyprland = {
    enable = true;
  };
  # enable appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  programs.localsend = {
    enable = true;
    openFirewall = true;
  };

  # List services that you want to enable:
  services.tailscale.enable = true;
  services.tailscale.package = nixpkgs-unstable.legacyPackages.${pkgs.system}.tailscale;
  services.tailscale.extraSetFlags = ["--netfilter-mode=nodivert"];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Environments
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
