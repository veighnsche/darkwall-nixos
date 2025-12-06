# TEAM_433: KDE Plasma desktop configuration
{ config, lib, pkgs, ... }:

{
  # Enable X11 and SDDM display manager
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # SDDM display manager (KDE's default)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;  # Use Wayland for SDDM
  };

  # KDE Plasma 6 desktop
  services.desktopManager.plasma6.enable = true;

  # Default to Wayland session
  services.displayManager.defaultSession = "plasma";

  # Enable Wayland support
  programs.xwayland.enable = true;

  # KDE system packages
  environment.systemPackages = with pkgs; [
    # KDE apps
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.ark
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.spectacle
    kdePackages.gwenview
    kdePackages.okular

    # KDE system utilities
    kdePackages.kde-cli-tools
    kdePackages.kscreen
    kdePackages.plasma-systemmonitor

    # Theming
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.breeze-icons

    # TEAM_433: XDG utilities for MIME/URL handling
    xdg-utils
  ];

  # GTK integration for KDE
  programs.dconf.enable = true;

  # ════════════════════════════════════════════════════════════════
  # TEAM_433: XDG Portal & Default Browser Configuration
  # Electron apps use BROWSER env var and xdg-open for opening URLs
  # ════════════════════════════════════════════════════════════════

  # XDG portal for Wayland screen sharing, file dialogs, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    # TEAM_433: Don't use portal for xdg-open - it's broken on KDE
    # The traditional xdg-open + BROWSER env var works better
    xdgOpenUsePortal = false;
  };

  # Enable system-wide MIME type handling
  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "text/html" = "firefox.desktop";
  };

  # BROWSER environment variable - Electron apps check this!
  environment.sessionVariables = {
    BROWSER = "firefox";
    DEFAULT_BROWSER = "firefox";
  };
}
