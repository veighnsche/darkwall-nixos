# TEAM_442: Desktop environment module
# KDE Plasma desktop (niri will be added gradually)
{ config, lib, pkgs, ... }:

{
  imports = [
    ./kde.nix
    ./audio.nix
    ./fonts.nix
  ];
}
