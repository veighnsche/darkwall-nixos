# Phase 1: Discovery - Wayland Desktop Feature

## Feature Summary

**Problem:** The darkwall-nixos repo needs the niri wayland compositor as an alternative to KDE Plasma, migrated from the old nixos repo.

**Who benefits:** Vince - prefers niri tiling compositor for daily work. Other users (guest) keep KDE Plasma.

**Goal:** Provide a working niri desktop environment that:
- Auto-logs Vince into niri on boot
- Keeps KDE Plasma available for other users
- Includes all supporting tools (waybar, rofi, swaylock, etc.)
- Doesn't conflict with KDE configuration

---

## Success Criteria

1. `just vm-run` boots to niri session for vince user
2. Logout shows tuigreet with both niri and Plasma sessions available
3. Waybar, wallpapers, and notifications work
4. Screen lock (swayidle/swaylock) works
5. Application launcher (rofi) works
6. No portal/screen-sharing conflicts between KDE and niri
7. KDE apps (dolphin, kate, etc.) work from within niri

---

## Current State Analysis

### What exists (TEAM_426 implementation)

**System-level (`modules/desktop/`):**
- `wayland/default.nix` - niri enablement, packages, XDG portals
- `greetd.nix` - auto-login vince to niri, tuigreet fallback

**User-level (`home/vince/`):**
- `wayland.nix` - mako, rofi, swaylock, systemd services
- `wayland/dotfiles/` - niri config, waybar, rofi, swaylock configs

### Known Issues (TEAM_439 review)

1. **XDG Portal Conflict**
   - kde.nix: `xdg.portal.extraPortals = [ xdg-desktop-portal-kde ]`
   - wayland/default.nix: `xdg.portal.extraPortals = [ xdg-desktop-portal-gtk ]`
   - Both set `xdg.portal.enable = true`
   - wlr portal enabled only in wayland module

2. **Missing Components**
   - `gtkgreet.css` - styled greeter (currently using tuigreet, so maybe not needed)
   - Desktop entries for wdisplays, clipboard-picker
   - Preflight niri config validation

3. **Hardcoded Values**
   - Monitor names in wallpaper script: DP-1, HDMI-A-2, HDMI-A-1
   - These are blep-specific, won't work on vm-test

---

## Codebase Reconnaissance

### Files Touched

| File | Purpose |
|------|---------|
| `modules/desktop/default.nix` | Imports wayland and greetd |
| `modules/desktop/kde.nix` | KDE config, SDDM (disabled), XDG portals |
| `modules/desktop/wayland/default.nix` | Niri system config |
| `modules/desktop/greetd.nix` | Display manager |
| `home/vince/default.nix` | Imports wayland.nix |
| `home/vince/wayland.nix` | Niri home config |
| `home/vince/wayland/dotfiles/*` | Config files |

### Potential Conflicts

1. **XDG Portals** - Both kde.nix and wayland/default.nix configure
2. **Environment Variables** - Both set sessionVariables (should merge fine)
3. **Display Manager** - greetd.nix uses `mkForce` to disable SDDM (correct)

### Tests/Validation Needed

- `just vm-run` - Full boot test
- `niri validate` - Config syntax check
- Screen sharing test (portal functionality)

---

## Constraints

1. **Must work on vm-test** - No real monitors, so wallpaper script may fail
2. **Must not break KDE** - Other users need working Plasma
3. **Must support auto-login** - No password prompt for vince
4. **Must have fallback** - tuigreet for logout/other users

---

## Open Questions (Phase 1)

### Q1: Do we need gtkgreet?
**Context:** Original implementation used gtkgreet with cage. Current uses tuigreet (TUI).
**Options:**
- A) Keep tuigreet (simpler, already working)
- B) Add gtkgreet for prettier graphical login
**Recommendation:** A - tuigreet is sufficient, especially with auto-login

### Q2: How to handle vm-test monitors?
**Context:** Wallpaper script hardcodes DP-1, HDMI-A-2, HDMI-A-1.
**Options:**
- A) Make wallpaper script dynamic (detect monitors)
- B) Make wallpaper config host-specific
- C) Use a single wallpaper for all monitors (simpler)
**Recommendation:** C for now - simplest for vm testing

### Q3: Desktop entries - needed?
**Context:** Old repo had wdisplays and clipboard-picker entries.
**Options:**
- A) Add them now
- B) Skip - can launch from rofi anyway
**Recommendation:** B - not critical for initial testing

---

## Phase 1 Complete

**Next:** Phase 2 - Design (resolve portal conflict, behavioral decisions)
