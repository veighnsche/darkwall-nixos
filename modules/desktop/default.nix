# TEAM_426: Desktop environment module
{ config, lib, pkgs, ... }:

{
  imports = [
    ./kde.nix
    ./audio.nix
    ./fonts.nix
  ];
}
