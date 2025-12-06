# TEAM_426: Base system configuration module
# Imported by all NixOS hosts
{ config, lib, pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./boot.nix
    ./networking.nix
    ./locale.nix
  ];

  # Allow unfree packages (for Windsurf, etc.)
  nixpkgs.config.allowUnfree = true;

  # Core system packages available to all users
  environment.systemPackages = with pkgs; [
    # Essential CLI tools
    git
    vim
    wget
    curl
    htop
    tree
    file
    unzip
    zip

    # System utilities
    pciutils    # lspci
    usbutils    # lsusb
    lsof
    strace
  ];

  # Enable SSH for remote access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # System state version - DO NOT CHANGE after initial install
  system.stateVersion = "24.11";
}
