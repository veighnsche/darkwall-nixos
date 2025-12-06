# TEAM_426: User configuration module
# Defines system users and links to their home-manager configs
{ config, lib, pkgs, ... }:

{
  imports = [
    ./vince.nix
    ./guest.nix
  ];

  # Disable mutable users (all users defined declaratively)
  users.mutableUsers = false;

  # Default shell for all users
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
