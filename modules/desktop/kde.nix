# TEAM_433: KDE Plasma desktop configuration
# TEAM_442: Added niri compositor (Phase 2)
# TEAM_443: Added wayland essentials for niri (Phase 4)
{ config, lib, pkgs, ... }:

{
  # TEAM_442: Phase 2 - Enable niri compositor
  # This adds niri package and creates niri.desktop session file
  programs.niri.enable = true;
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

    # TEAM_443: Wayland essentials for niri (Phase 4)
    waybar        # Status bar
    rofi          # Launcher (krunner doesn't work in niri)
    mako          # Notifications
    libnotify     # notify-send command
    swaybg        # Wallpaper
    swaylock      # Screen lock
    swayidle      # Idle management
    wl-clipboard  # Clipboard
    grim          # Screenshots
    slurp         # Region selection
  ];

  # GTK integration for KDE
  programs.dconf.enable = true;

  # ════════════════════════════════════════════════════════════════
  # TEAM_433: XDG Portal & Default Browser Configuration
  # Electron apps use BROWSER env var and xdg-open for opening URLs
  # ════════════════════════════════════════════════════════════════

  # TEAM_442: XDG portal for KDE (reverted to simple config)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
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
