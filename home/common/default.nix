# TEAM_426: Common/base Home Manager configuration
# All users inherit from this - contains KDE defaults and essentials
{ config, pkgs, lib, ... }:

{
  imports = [
    ./kde-apps.nix
    ./shell-base.nix
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ════════════════════════════════════════════════════════════════
  # XDG Base Directories
  # ════════════════════════════════════════════════════════════════
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}
