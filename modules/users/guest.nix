# TEAM_426: Guest user configuration (system-level)
{ config, lib, pkgs, ... }:

{
  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [
      "networkmanager"  # network management
      "video"           # GPU access
      "audio"           # audio devices
    ];
    # No wheel = no sudo

    # Password is set per-host (see hosts/*/default.nix)
  };

  # Link to Home Manager configuration
  home-manager.users.guest = import ../../home/guest;
}
