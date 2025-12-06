# TEAM_426: Vince's Home Manager configuration for STANDALONE use (non-NixOS)
# This file is used when running home-manager on Fedora/other distros
# Note: On Fedora, KDE apps are already installed system-wide, so we skip common/kde-apps
{ config, pkgs, lib, configDir, ... }:

let
  mkWindsurfSymlink = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${configDir}/dotfiles/windsurf/${path}";
  };
in
{
  imports = [
    ../common/shell-base.nix  # Just the shell basics (Fedora has KDE apps)
    ./shell.nix               # Power-user shell (zsh, starship)
    ./programs.nix            # Git, dev tools config
  ];

  # ════════════════════════════════════════════════════════════════
  # User Identity
  # ════════════════════════════════════════════════════════════════
  home.username = "vince";
  home.homeDirectory = "/home/vince";
  home.stateVersion = "25.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

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

    # Code editors
    darkwall-windsurf
  ];

  # ════════════════════════════════════════════════════════════════
  # Windsurf Configuration
  # ════════════════════════════════════════════════════════════════
  home.file = {
    ".codeium/windsurf/mcp_config.json" = mkWindsurfSymlink "mcp_config.json";
    ".codeium/windsurf/memories/global_rules.md" = mkWindsurfSymlink "global_rules.md";
    ".codeium/windsurf/global_workflows" = mkWindsurfSymlink "workflows";
  };

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
