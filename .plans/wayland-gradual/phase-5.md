# Phase 5: Add User Services (One at a Time)

## Goal
Add systemd user services to auto-start niri helpers.

## Changes - Add ONE at a time, test after each

### Step 1: Waybar service
```nix
systemd.user.services.waybar = {
  Unit = {
    Description = "Waybar";
    PartOf = [ "graphical-session.target" ];
    After = [ "graphical-session.target" ];
  };
  Service = {
    ExecStart = "${pkgs.waybar}/bin/waybar";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "graphical-session.target" ];
};
```
**Test:** Log into niri → waybar appears automatically

### Step 2: Mako service
```nix
services.mako.enable = true;
```
**Test:** `notify-send "test"` works

### Step 3: Wallpaper service
```nix
systemd.user.services.swaybg = {
  Unit = {
    Description = "Wallpaper";
    PartOf = [ "graphical-session.target" ];
    After = [ "graphical-session.target" ];
  };
  Service = {
    ExecStart = "${pkgs.swaybg}/bin/swaybg -i /path/to/wallpaper.jpg -m fill";
    Restart = "on-failure";
  };
  Install.WantedBy = [ "graphical-session.target" ];
};
```
**Test:** Wallpaper appears on login

## Exit Criteria
- [ ] Waybar auto-starts
- [ ] Notifications work
- [ ] Wallpaper appears
