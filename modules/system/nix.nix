# TEAM_426: Nix daemon and flakes configuration
{ config, lib, pkgs, ... }:

{
  nix = {
    # Enable flakes and new nix command
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Optimize storage
      auto-optimise-store = true;
      # Trusted users for remote builds
      trusted-users = [ "root" "@wheel" ];
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Note: nix-daemon is always running on NixOS (no need to enable it)
}
