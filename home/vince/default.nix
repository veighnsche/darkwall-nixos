# TEAM_427: Vince's Home Manager configuration (NixOS integrated)
# Extends common/ with power-user tools and dev environment
{ config, pkgs, lib, ... }:

{
  imports = [
    ../common           # Inherit all base config (KDE apps, essentials)
    ./shell.nix         # Power-user shell (zsh, starship)
    ./programs.nix      # Git, dev tools config
    ./windsurf          # Windsurf IDE + dotfiles symlinks
  ];

  # ════════════════════════════════════════════════════════════════
  # User Identity
  # ════════════════════════════════════════════════════════════════
  home.username = "vince";
  home.homeDirectory = "/home/vince";
  home.stateVersion = "24.11";

  # ════════════════════════════════════════════════════════════════
  # Power User Packages (on top of common/)
  # ════════════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # Better CLI tools (upgrades from common/)
    bat           # cat with syntax highlighting
    eza           # ls replacement
    ripgrep       # fast grep
    fd            # find replacement
    fzf           # fuzzy finder
    jq            # JSON processor
    yq-go         # YAML processor

    # Remote access
    mosh

    # Network tools
    prettyping
    httpie

    # Advanced monitoring
    btop          # better htop

    # Power editors
    helix
    neovim

    # Dev tools
    nodejs_22
    uv            # fast Python package manager
    git           # version control (for CLI use)
  ];

  # Override konsole profile from common/
  programs.konsole.profiles."Default".command = "${pkgs.zsh}/bin/zsh";
}
