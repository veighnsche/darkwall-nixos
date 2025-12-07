# TEAM_442: Phase 3 - Niri configuration based on official default
# TEAM_443: Added rofi launcher binding (Phase 4)
{ config, pkgs, ... }:

{
  xdg.configFile."niri/config.kdl".text = ''
    // TEAM_442: Niri config based on official default-config.kdl
    // https://github.com/YaLTeR/niri/blob/main/resources/default-config.kdl

    input {
      keyboard {
        xkb { }
        numlock
      }

      touchpad {
        tap
        natural-scroll
      }

      mouse { }
    }

    // Cursor settings - IMPORTANT for mouse to work
    cursor {
      xcursor-theme "breeze_cursors"
      xcursor-size 24
    }

    layout {
      gaps 16
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }

      focus-ring {
        width 4
        active-color "#7fc8ff"
        inactive-color "#505050"
      }

      border {
        off
      }
    }

    // Hotkey overlay at startup
    hotkey-overlay { }

    // Screenshot path
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations { }

    // TEAM_443: Auto-start waybar and mako
    spawn-at-startup "waybar"
    spawn-at-startup "mako"

    binds {
      // Show hotkey help
      Mod+Shift+Slash { show-hotkey-overlay; }

      // Terminal - use konsole from KDE
      Mod+T { spawn "konsole"; }
      Mod+Return { spawn "konsole"; }

      // TEAM_443: Launcher - rofi (krunner doesn't work in niri)
      Mod+D { spawn "rofi" "-show" "drun"; }

      // Close window
      Mod+Q { close-window; }

      // Exit niri
      Mod+Shift+E { quit; }

      // Window navigation
      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }
      Mod+H     { focus-column-left; }
      Mod+J     { focus-window-down; }
      Mod+K     { focus-window-up; }
      Mod+L     { focus-column-right; }

      // Move windows
      Mod+Ctrl+Left  { move-column-left; }
      Mod+Ctrl+Down  { move-window-down; }
      Mod+Ctrl+Up    { move-window-up; }
      Mod+Ctrl+Right { move-column-right; }
      Mod+Ctrl+H     { move-column-left; }
      Mod+Ctrl+J     { move-window-down; }
      Mod+Ctrl+K     { move-window-up; }
      Mod+Ctrl+L     { move-column-right; }

      // Workspaces
      Mod+Page_Down { focus-workspace-down; }
      Mod+Page_Up   { focus-workspace-up; }
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }

      // Window sizing
      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+C { center-column; }
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }

      // Floating
      Mod+V { toggle-window-floating; }

      // Screenshot
      Print { screenshot; }
      Ctrl+Print { screenshot-screen; }
      Alt+Print { screenshot-window; }

      // Power off monitors
      Mod+Shift+P { power-off-monitors; }
    }
  '';
}
