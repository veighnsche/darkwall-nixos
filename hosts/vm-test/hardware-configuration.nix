# TEAM_426: Hardware configuration for VM test
# This is a generic VM hardware config - will be regenerated on actual hardware
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Filesystems (adjust based on your VM disk setup)
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  # Swap (optional)
  swapDevices = [ ];

  # VM hardware
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  # Network interface (virtio)
  networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
}
