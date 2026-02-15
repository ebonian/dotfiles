{pkgs, ...}: {
  # Enable the core Bluetooth backend (BlueZ)
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Enable battery reporting for Bluetooth headphones
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  # Ensure MediaTek MT7922 firmware blobs can load
  hardware.enableRedistributableFirmware = true;

  # Blueman service for system tray applet
  services.blueman.enable = true;
}
