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
  # Do NOT enable iwd here. NetworkManager's default backend is wpa_supplicant,
  # and `networking.wireless.iwd.enable = true` (without also setting
  # networking.networkmanager.wifi.backend = "iwd") left BOTH wpa_supplicant and
  # iwd running on wlan0 at once. The redundant iwd periodically issued scans on
  # the shared radio, pulling it off-channel for a few seconds — measured as
  # recurring 5ms→150ms latency walls to the AP that Moonlight reports as
  # "frames dropped by your network connection". One supplicant only.
  # networking.wireless.iwd.enable = true;
  # Disable WiFi power-save. The MT7921 radio dozing between beacons injects
  # periodic latency spikes that wreck low-latency streaming (Moonlight) — the
  # hitching is bitrate-independent because it's latency, not bandwidth. The NM
  # option states intent, but this host uses the *iwd* backend (not
  # wpa_supplicant), and NM does not reliably push power-save down to the driver
  # there. So a dispatcher script hard-sets it off via `iw` on every
  # interface-up: backend-agnostic and re-applied across reconnects/roams.
  networking.networkmanager.wifi.powersave = false;
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "wifi-powersave-off" ''
        # Match any wireless interface by sysfs, not a hardcoded name:
        # removing iwd let systemd rename wlan0 -> wlp3s0, which would have
        # silently broken a name-pinned check.
        if [ "$2" = "up" ] && [ -e "/sys/class/net/$1/wireless" ]; then
          ${pkgs.iw}/bin/iw dev "$1" set power_save off
        fi
      '';
    }
  ];
  networking.nameservers = ["1.1.1.1"];
  # Tailscale MagicDNS needs a DNS manager it can own without racing the network
  # stack. Without systemd-resolved, tailscaled falls back to the "openresolv"
  # mode and registers 100.100.100.100 in /etc/resolv.conf directly — but every
  # time NetworkManager regenerates resolv.conf (e.g. an iPhone-hotspot reconnect),
  # it wipes tailscale's resolver entry. The resolver then has no upstreams and
  # SERVFAILs *all* queries, including the host's own *.ts.net name. Enabling
  # systemd-resolved gives tailscaled a stable D-Bus split-DNS interface (tailnet
  # suffix -> 100.100.100.100, everything else -> normal DNS); NixOS auto-switches
  # NetworkManager to the resolved backend so the two cooperate instead of fighting
  # over resolv.conf. Survives network changes.
  services.resolved.enable = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [8081 19000 19001 25565];
    allowedUDPPorts = [8081 19000 19001 25565];
    # Fix Discord voice stuck on "DTLS connecting" when Tailscale is up. Discord's
    # WebRTC (in Legcord/Vesktop) binds an ICE socket to the tailscale0 interface,
    # then hangs the DTLS handshake on it. Drop any tailnet-sourced packet leaving
    # the tailnet so that candidate fails fast and WebRTC falls back to wlan0. This
    # only touches traffic sourced from the 100.64/10 CGNAT range headed off-tailnet,
    # so normal internet, tailnet peer/SSH traffic, and MagicDNS are unaffected.
    # (Would interfere only with peer-advertised subnet routes or an exit node, which
    # this host doesn't use.) See https://github.com/Legcord/Legcord/issues/1011
    extraCommands = ''
      iptables -I OUTPUT -s 100.64.0.0/10 ! -d 100.64.0.0/10 -j DROP
    '';
    extraStopCommands = ''
      iptables -D OUTPUT -s 100.64.0.0/10 ! -d 100.64.0.0/10 -j DROP || true
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
  # Cap the tailscale0 tunnel MTU. Default is 1280, but low-MTU uplinks
  # (e.g. iPhone Personal Hotspot, path MTU ~1200) black-hole the oversized
  # WireGuard packets — SSH hangs at the post-quantum KEX reply while ping
  # still works. 1100 keeps every outer packet under the path limit.
  systemd.services.tailscaled.environment.TS_DEBUG_MTU = "1100";

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
