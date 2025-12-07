# Phase 6: Replace SDDM with greetd (Optional)

## Goal
Replace SDDM with greetd for auto-login to niri.

**NOTE:** Only do this after phases 1-5 work perfectly!

## Changes

### Step 1: Create greetd.nix
```nix
{ config, lib, pkgs, ... }:
{
  services.displayManager.sddm.enable = lib.mkForce false;
  
  services.greetd = {
    enable = true;
    restart = false;
    settings = {
      initial_session = {
        command = "niri-session";
        user = "vince";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:${config.services.displayManager.sessionData.desktops}/share/xsessions";
        user = "greeter";
      };
    };
  };
  
  systemd.tmpfiles.rules = [
    "d '/var/cache/tuigreet' 0755 greeter greeter - -"
  ];
}
```

## Verification
1. VM boots directly to niri (no login screen)
2. Logout shows tuigreet
3. Can log back in

## Exit Criteria
- [ ] Auto-login works
- [ ] Logout shows tuigreet
- [ ] Can switch to Plasma from tuigreet
