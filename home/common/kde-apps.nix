# TEAM_426: Default KDE applications (matches Fedora KDE defaults)
# These are available to all users
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # ════════════════════════════════════════════════════════════════
    # Core KDE Applications
    # ════════════════════════════════════════════════════════════════
    
    # File Management
    kdePackages.dolphin              # File manager
    kdePackages.dolphin-plugins      # Extra functionality
    kdePackages.ark                  # Archive manager
    kdePackages.filelight            # Disk usage visualizer
    
    # Terminal
    kdePackages.konsole              # Terminal emulator
    
    # Text Editors
    kdePackages.kate                 # Advanced text editor (includes kwrite functionality)
    
    # Graphics & Media
    kdePackages.gwenview             # Image viewer
    kdePackages.okular               # Document viewer (PDF, etc.)
    kdePackages.spectacle            # Screenshot tool
    kdePackages.kolourpaint          # Simple image editor
    kdePackages.dragon               # Video player
    kdePackages.elisa                # Music player
    kdePackages.kamoso               # Webcam
    
    # Utilities
    kdePackages.kcalc                # Calculator
    kdePackages.kcharselect          # Character picker
    kdePackages.kwalletmanager       # Password manager
    
    # System Tools
    kdePackages.kinfocenter          # System information
    kdePackages.khelpcenter          # Help & documentation
    kdePackages.ksystemlog           # Log viewer
    kdePackages.plasma-systemmonitor # System monitor
    kdePackages.partitionmanager     # Disk partitioning
    
    # Remote Desktop
    kdePackages.krdc                 # Remote desktop client
    kdePackages.krfb                 # Desktop sharing
    
    # KDE Connect (phone integration)
    kdePackages.kdeconnect-kde
    
    # ════════════════════════════════════════════════════════════════
    # Web Browser
    # ════════════════════════════════════════════════════════════════
    firefox
    
    # ════════════════════════════════════════════════════════════════
    # Office Suite
    # ════════════════════════════════════════════════════════════════
    libreoffice-qt6-fresh            # LibreOffice with Qt6/KDE integration
    
    # ════════════════════════════════════════════════════════════════
    # Media
    # ════════════════════════════════════════════════════════════════
    vlc                              # Versatile media player
  ];

  # ════════════════════════════════════════════════════════════════
  # Program Configurations
  # ════════════════════════════════════════════════════════════════
  
  programs.firefox.enable = true;
  
  programs.konsole = {
    enable = true;
    defaultProfile = "Default";
    profiles = {
      "Default" = {
        font = {
          name = "Hack Nerd Font";
          size = 11;
        };
      };
    };
  };
}
