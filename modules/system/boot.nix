# TEAM_426: Boot configuration
# Note: hardware-specific bootloader config should go in hosts/*/hardware-configuration.nix
{ config, lib, pkgs, ... }:

{
  # Use systemd-boot by default (can be overridden per-host)
  boot.loader = {
    systemd-boot = {
      enable = lib.mkDefault true;
      configurationLimit = 10;  # Keep last 10 generations
    };
    efi.canTouchEfiVariables = lib.mkDefault true;
  };

  # Latest kernel by default
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  # Enable kernel modules for common hardware
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];
}
