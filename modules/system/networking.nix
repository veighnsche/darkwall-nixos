# TEAM_426: Network configuration
{ config, lib, pkgs, ... }:

{
  # Use NetworkManager for easy network management
  networking.networkmanager.enable = true;

  # Disable the default DHCP daemon (NetworkManager handles it)
  networking.useDHCP = lib.mkDefault false;

  # Enable resolved for DNS
  services.resolved.enable = true;

  # Firewall is enabled in default.nix
}
