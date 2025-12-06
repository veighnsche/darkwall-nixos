# TEAM_426: Guest Home Manager configuration
# Inherits all common/base config (KDE apps, essentials)
# Guest has everything a normal user needs, just no power-user tools
{ config, pkgs, lib, ... }:

{
  imports = [
    ../common  # Inherit all base config
  ];

  # ════════════════════════════════════════════════════════════════
  # User Identity
  # ════════════════════════════════════════════════════════════════
  home.username = "guest";
  home.homeDirectory = "/home/guest";
  home.stateVersion = "24.11";

  # Guest-specific: Nothing extra needed!
  # All KDE apps, Firefox, LibreOffice, etc. come from common/
}
