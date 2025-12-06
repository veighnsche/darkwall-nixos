# TEAM_433: Base Home Manager configuration (shared by NixOS and Fedora)
# Contains: XDG, MIME associations, darkwall-windsurf, shell-base
# Does NOT contain: KDE apps (Fedora has them system-wide)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./shell-base.nix
    ./darkwall-windsurf
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # ════════════════════════════════════════════════════════════════
  # XDG Base Directories
  # ════════════════════════════════════════════════════════════════
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    # TEAM_432: MIME type associations
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Firefox as default browser
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";

        # Windsurf for code/text files (desktop file is darkwall-windsurf.desktop)
        "text/plain" = "darkwall-windsurf.desktop";
        "text/x-python" = "darkwall-windsurf.desktop";
        "text/x-script.python" = "darkwall-windsurf.desktop";
        "text/x-java" = "darkwall-windsurf.desktop";
        "text/x-c" = "darkwall-windsurf.desktop";
        "text/x-c++" = "darkwall-windsurf.desktop";
        "text/x-chdr" = "darkwall-windsurf.desktop";
        "text/x-csrc" = "darkwall-windsurf.desktop";
        "text/x-c++src" = "darkwall-windsurf.desktop";
        "text/x-c++hdr" = "darkwall-windsurf.desktop";
        "text/javascript" = "darkwall-windsurf.desktop";
        "application/javascript" = "darkwall-windsurf.desktop";
        "application/json" = "darkwall-windsurf.desktop";
        "text/x-shellscript" = "darkwall-windsurf.desktop";
        "application/x-shellscript" = "darkwall-windsurf.desktop";
        "text/x-rust" = "darkwall-windsurf.desktop";
        "text/x-go" = "darkwall-windsurf.desktop";
        "text/x-nix" = "darkwall-windsurf.desktop";
        "text/markdown" = "darkwall-windsurf.desktop";
        "text/x-markdown" = "darkwall-windsurf.desktop";
        "application/toml" = "darkwall-windsurf.desktop";
        "application/x-yaml" = "darkwall-windsurf.desktop";
        "text/yaml" = "darkwall-windsurf.desktop";
        "text/xml" = "darkwall-windsurf.desktop";
        "application/xml" = "darkwall-windsurf.desktop";
      };
    };
  };
}
