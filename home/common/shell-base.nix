# TEAM_426: Base shell configuration for all users
{ config, pkgs, lib, ... }:

{
  # Basic bash for all users (zsh can be added per-user)
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -alh";
      la = "ls -a";
      lt = "ls -ltrh";
    };
  };

  # Basic CLI tools everyone should have
  home.packages = with pkgs; [
    # File operations
    tree
    file
    unzip
    zip
    p7zip
    
    # Text processing
    less
    
    # System info
    htop
    fastfetch
  ];
}
