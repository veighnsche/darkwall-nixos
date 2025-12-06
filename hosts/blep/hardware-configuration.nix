# TEAM_434: blep hardware configuration
# Intel i5-1240P, 64GB RAM, Iris Xe, 1TB NVMe
# Dual-boot: NixOS + Fedora
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ════════════════════════════════════════════════════════════════
  # TEAM_437: Filesystem Layout (Dual-boot with Fedora)
  # ════════════════════════════════════════════════════════════════
  # Target layout:
  #   nvme0n1p1: 600M  EFI   (shared between NixOS and Fedora)
  #   nvme0n1p2: 2G    /boot (Fedora only)
  #   nvme0n1p3: 100G  btrfs (Fedora root + home)
  #   nvme0n1p4: 815G  ext4  (NixOS root)
  #   nvme0n1p5: 16G   swap  (NixOS swap)
  # ════════════════════════════════════════════════════════════════

  # NixOS root - UPDATE after partitioning
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";  # TODO: Create with `mkfs.ext4 -L nixos`
    fsType = "ext4";
  };

  # Shared EFI partition (already exists)
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/2451-5874";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # Swap - UPDATE after partitioning
  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }  # TODO: Create with `mkswap -L swap`
  ];

  # Intel 12th Gen CPU
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Power management for laptop
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
