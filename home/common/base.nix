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
  # XDG Base Directories & MIME Associations
  # ════════════════════════════════════════════════════════════════
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };

    # TEAM_433: MIME type associations
    # KDE/GNOME overwrite ~/.config/mimeapps.list, so we use a workaround:
    # 1. Don't manage ~/.config/mimeapps.list (let desktop env use it)
    # 2. Write to ~/.local/share/applications/mimeapps.list (fallback location)
    # 3. Desktop reads fallback if no user preference is set
    mime.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Firefox as default browser (URL scheme handlers)
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
        "x-scheme-handler/mailto" = "firefox.desktop";

        # HTML/web content
        "text/html" = "firefox.desktop";
        "application/xhtml+xml" = "firefox.desktop";
        "application/x-extension-htm" = "firefox.desktop";
        "application/x-extension-html" = "firefox.desktop";
        "application/x-extension-shtml" = "firefox.desktop";
        "application/x-extension-xhtml" = "firefox.desktop";
        "application/x-extension-xht" = "firefox.desktop";

        # Windsurf URL scheme handler (for OAuth callbacks)
        "x-scheme-handler/windsurf" = "darkwall-windsurf-url-handler.desktop";
        "x-scheme-handler/vscode" = "darkwall-windsurf-url-handler.desktop";

        # Windsurf for code/text files
        "text/plain" = "darkwall-windsurf.desktop";
        "inode/directory" = "darkwall-windsurf.desktop";
        "application/x-code-workspace" = "darkwall-windsurf.desktop";
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

  # TEAM_433: Force overwrite mimeapps.list to handle KDE/GNOME conflicts
  # This writes to ~/.local/share/applications/mimeapps.list (fallback location)
  # while letting KDE freely edit ~/.config/mimeapps.list
  xdg.configFile."mimeapps.list".force = true;
}
