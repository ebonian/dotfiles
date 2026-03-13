{pkgs, ...}: {
  services.udev.packages = [pkgs.arduino-core];
}
