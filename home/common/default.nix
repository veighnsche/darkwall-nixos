# TEAM_433: NixOS Home Manager configuration
# Imports base (shared) + KDE apps (NixOS-specific)
# For Fedora/standalone, use base.nix directly (skips KDE apps)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix      # Shared: XDG, mimeApps, darkwall-windsurf, shell-base
    ./kde-apps.nix  # NixOS only: KDE applications
  ];
}
