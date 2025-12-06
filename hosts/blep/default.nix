# TEAM_434: blep - Daily driver desktop
# Intel i5-1240P, 64GB RAM, Iris Xe
# Dual-boot: NixOS + Fedora (separate partitions)
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "blep";

  # ════════════════════════════════════════════════════════════════
  # Boot Configuration (Dual-boot with Fedora)
  # ════════════════════════════════════════════════════════════════
  
  boot.loader = {
    # Use GRUB for dual-boot (detects Fedora via os-prober)
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";  # EFI install
      efiSupport = true;
      useOSProber = true;  # Detect Fedora
    };
    efi.canTouchEfiVariables = true;
  };

  # ════════════════════════════════════════════════════════════════
  # Hardware
  # ════════════════════════════════════════════════════════════════
  
  # Intel Iris Xe graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver  # VAAPI
      vpl-gpu-rt          # QSV
    ];
  };
  
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  
  # Audio (PipeWire)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  # ════════════════════════════════════════════════════════════════
  # Desktop Environment
  # ════════════════════════════════════════════════════════════════
  
  # KDE Plasma (via modules/desktop)
  # Configured in modules/desktop/kde.nix
  
  # ════════════════════════════════════════════════════════════════
  # Networking
  # ════════════════════════════════════════════════════════════════
  
  networking.networkmanager.enable = true;
  
  # WiFi with MAC randomization
  networking.networkmanager.wifi.macAddress = "random";
  
  # ════════════════════════════════════════════════════════════════
  # User Configuration
  # ════════════════════════════════════════════════════════════════
  
  # Allow password changes after install (set password with `passwd`)
  users.mutableUsers = lib.mkForce true;
  
  # Initial password for first boot (change immediately!)
  users.users.vince.initialPassword = "changeme";
  
  # ════════════════════════════════════════════════════════════════
  # Desktop Packages
  # ════════════════════════════════════════════════════════════════
  
  environment.systemPackages = with pkgs; [
    # Browsers
    firefox
    chromium
    
    # Development
    pkgs.darkwall-windsurf
    
    # Media
    vlc
    mpv
    
    # Utilities
    flameshot    # Screenshots
    keepassxc    # Password manager
  ];
}
