# Phase 4: Add Essential Packages

## Goal
Add packages needed for a usable niri session.

## Changes

### Step 1: Add wayland essentials
In `modules/desktop/kde.nix` or new `modules/desktop/niri.nix`:

```nix
environment.systemPackages = with pkgs; [
  # For niri
  waybar      # Status bar
  rofi        # Launcher (krunner doesn't work in niri)
  mako        # Notifications
  swaybg      # Wallpaper
  swaylock    # Screen lock
  swayidle    # Idle management
  wl-clipboard # Clipboard
  grim        # Screenshots
  slurp       # Region selection
];
```

## Verification
```bash
git add -A && just vm-run
```

1. Log into niri
2. Run `waybar` from terminal → bar appears
3. Run `rofi -show drun` → launcher works
4. Run `notify-send "test"` → notification appears

## Exit Criteria
- [ ] Packages installed
- [ ] Can manually run waybar
- [ ] Can manually run rofi
- [ ] Notifications work
