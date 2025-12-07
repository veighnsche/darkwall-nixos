# TEAM_433: Vince's Home Manager configuration for STANDALONE use (non-NixOS)
# This file is used when running home-manager on Fedora/other distros
# Imports common/base.nix (shared config) but skips KDE apps (Fedora has them)
#
# TEAM_443: SELinux setup required for Fedora - run ONCE:
#   sudo semodule -i scripts/fedora/nix-sandbox.pp
{ config, pkgs, lib, ... }:

{
  imports = [
    ../common/base.nix  # Shared: XDG, mimeApps, darkwall-windsurf, shell-base
    ./shell.nix         # Power-user shell (zsh, starship)
    ./programs.nix      # Git, dev tools config
  ];

  # ════════════════════════════════════════════════════════════════
  # User Identity
  # ════════════════════════════════════════════════════════════════
  home.username = "vince";
  home.homeDirectory = "/home/vince";
  home.stateVersion = "25.11";

  # ════════════════════════════════════════════════════════════════
  # Non-NixOS Integration
  # ════════════════════════════════════════════════════════════════
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  xdg.systemDirs.data = [
    "${config.home.homeDirectory}/.nix-profile/share"
    "/nix/var/nix/profiles/default/share"
  ];

  # ════════════════════════════════════════════════════════════════
  # Packages (Fedora already has KDE, so just add dev tools)
  # ════════════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # Desktop integration
    hicolor-icon-theme

    # Better CLI tools
    bat
    eza
    ripgrep
    fd
    fzf
    jq
    yq-go

    # Remote access
    mosh

    # Network tools
    prettyping
    httpie

    # System monitoring
    btop

    # Editors
    helix
    neovim

    # Dev tools
    nodejs_22
    uv
    git
  ];
}
