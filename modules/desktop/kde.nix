# TEAM_426: KDE Plasma desktop configuration
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
  ];

  # GTK integration for KDE
  programs.dconf.enable = true;

  # XDG portal for Wayland screen sharing, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  };
}
