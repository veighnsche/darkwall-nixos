# TEAM_426: Font configuration
{ config, lib, pkgs, ... }:

{
  fonts = {
    # Enable default fonts
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Nerd fonts for terminal/coding
      nerd-fonts.hack
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

      # System fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      ubuntu-classic

      # Microsoft fonts compatibility
      corefonts
      vista-fonts
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Hack Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
