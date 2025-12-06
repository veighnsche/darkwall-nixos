# TEAM_426: VM test host configuration
# For testing NixOS configuration in a VM before deploying to real hardware
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Include VM-specific hardware config
    ./hardware-configuration.nix
  ];

  # Hostname
  networking.hostName = "vm-test";

  # VM-specific settings
  # ════════════════════════════════════════════════════════════════

  # VM resource configuration
  virtualisation.vmVariant.virtualisation = {
    cores = 8;
    memorySize = 16 * 1024;  # 16GB in MB
    diskSize = 50 * 1024;    # 50GB in MB
  };

  # Enable QEMU guest agent
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Autologin for testing (remove in production!)
  services.displayManager.autoLogin = {
    enable = true;
    user = "vince";
  };

  # Enable SSH with password auth for initial testing
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;

  # Disable mutableUsers override to allow password changes during testing
  users.mutableUsers = lib.mkForce true;

  # Simple password for testing (vince:vince, guest:guest)
  users.users.vince.initialPassword = lib.mkForce "vince";
  users.users.guest.initialPassword = lib.mkForce "guest";

  # VM performance settings
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Enable virtio for better VM performance
  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
  ];

  # Use GRUB for VM (easier debugging than systemd-boot)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";  # Adjust based on your VM setup
  };
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # Additional VM packages
  environment.systemPackages = with pkgs; [
    # For clipboard sharing in VM
    spice-vdagent
  ];
}
