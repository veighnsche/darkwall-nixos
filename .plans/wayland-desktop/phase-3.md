# Phase 3: Implementation - Wayland Desktop Feature

## Implementation Units of Work

Based on Phase 2 design decisions, the following fixes are needed:

---

## UoW 1: Fix XDG Portal Configuration

**File:** `modules/desktop/wayland/default.nix`

**Change:** Remove duplicate portal config from wayland module. Move to consolidated approach.

**New approach:** Create portal config that works for both DEs.

### Option A: Modify wayland/default.nix

Remove the `xdg.portal` block entirely from wayland module. Add only `wlr.enable`:

```nix
# In wayland/default.nix - REMOVE this entire block:
# xdg.portal = {
#   enable = true;
#   wlr.enable = true;
#   extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
#   config = { ... };
# };

# ADD only this:
xdg.portal.wlr.enable = true;
```

### Option B: Modify kde.nix to be comprehensive

Update kde.nix to handle both DEs:

```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;  # For niri screen sharing
  extraPortals = with pkgs; [
    kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-gtk
  ];
  xdgOpenUsePortal = false;
  config = {
    kde.default = [ "kde" "gtk" ];
    plasma.default = [ "kde" "gtk" ];
    niri = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };
};
```

**Recommended:** Option B - centralize in kde.nix, remove from wayland.

---

## UoW 2: Add greetd restart=false

**File:** `modules/desktop/greetd.nix`

**Change:** Add restart prevention to avoid killing sessions during rebuild.

```nix
services.greetd = {
  enable = true;
  restart = false;  # ADD THIS LINE
  settings = { ... };
};
```

---

## UoW 3: Simplify Wallpaper Script

**File:** `home/vince/wayland.nix`

**Change:** Make wallpaper script handle missing monitors gracefully.

**Option A (simple):** Single wallpaper for all monitors

```nix
swaybgLauncher = pkgs.writeShellScript "niri-swaybg-launch" ''
  set -euo pipefail
  # Use first available wallpaper for all monitors
  wp="${config.home.homeDirectory}/Pictures/wallpaper.jpg"
  if [ ! -f "$wp" ]; then
    # Fallback to solid color if no wallpaper
    exit 0
  fi
  ${pkgs.swaybg}/bin/swaybg -i "$wp" -m fill
'';
```

**Option B (dynamic):** Detect monitors at runtime

```nix
swaybgLauncher = pkgs.writeShellScript "niri-swaybg-launch" ''
  set -euo pipefail
  
  wp="${config.home.homeDirectory}/Pictures/wallpaper.jpg"
  [ ! -f "$wp" ] && exit 0
  
  # Launch swaybg for each connected output
  niri msg outputs 2>/dev/null | grep -oP '(?<=Output ")[^"]+' | while read -r output; do
    ${pkgs.swaybg}/bin/swaybg -o "$output" -i "$wp" -m fill &
  done
  
  wait
'';
```

**Recommended:** Option A for simplicity. User can enhance later.

---

## UoW 4: Update Documentation

**Files:**
- `.teams/TEAM_426_wayland_desktop.md` - Update to reflect auto-login change
- `.teams/TEAM_439_review_wayland_impl.md` - Mark issues as addressed

---

## Implementation Order

1. **UoW 1** - Portal fix (CRITICAL - must be first)
2. **UoW 2** - greetd restart (quick fix)
3. **UoW 3** - Wallpaper simplification (enables vm-test)
4. **UoW 4** - Documentation update

---

## Verification

After all UoWs complete:

```bash
# Syntax check
nix-instantiate --parse modules/desktop/wayland/default.nix
nix-instantiate --parse modules/desktop/greetd.nix
nix-instantiate --parse modules/desktop/kde.nix

# Full build test
just vm-run
```

---

## Phase 3 Checklist

- [ ] UoW 1: Portal configuration consolidated
- [ ] UoW 2: greetd restart=false added
- [ ] UoW 3: Wallpaper script simplified
- [ ] UoW 4: Documentation updated
- [ ] Syntax validation passed
- [ ] `just vm-run` tested

---

## Phase 3 Complete

**Next:** Phase 4 - Testing and Validation
