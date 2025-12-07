# Phase 2: Design - Wayland Desktop Feature

## Design Goal

Resolve conflicts and finalize the architecture for niri + KDE coexistence.

---

## Critical Design Decision: XDG Portal Configuration

### Current State

**kde.nix:**
```nix
xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
  xdgOpenUsePortal = false;
};
```

**wayland/default.nix:**
```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  config.niri = {
    default = [ "gtk" ];
    "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };
};
```

### Problem

NixOS merges these, resulting in:
- `extraPortals = [ kde gtk ]` (both installed)
- `wlr.enable = true` (wlr portal for screen sharing)
- Config has `niri` section but no `kde` section

### Design Options

**Option A: Session-specific portal selection (recommended)**

Use `xdg.portal.config` to route portals per-desktop:

```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = with pkgs; [
    kdePackages.xdg-desktop-portal-kde
    xdg-desktop-portal-gtk
  ];
  config = {
    # KDE Plasma uses KDE portal
    kde = {
      default = [ "kde" "gtk" ];
    };
    plasma = {
      default = [ "kde" "gtk" ];
    };
    # Niri uses GTK portal (wlr for screen share)
    niri = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };
};
```

**Option B: Remove portal config from wayland module**

Let kde.nix be the single source, only add `wlr.enable` in wayland module.

**Option C: Separate portal config to its own module**

Create `modules/desktop/portals.nix` that handles all portal configuration.

### Decision

**Choose Option A** - Session-specific routing.

Rationale:
- Both portals installed (needed for both DEs)
- Each DE uses its preferred portal
- Screen sharing works for niri (wlr) and KDE (native)
- Single merged config, no conflicts

---

## Behavioral Decisions

### B1: Wallpaper Handling

**Decision:** Use single fallback wallpaper for vm-test, keep multi-monitor for blep.

**Implementation:**
```nix
# In wallpaper script, handle missing monitors gracefully
if niri msg outputs | grep -q "DP-1"; then
  swaybg -o DP-1 -i "$wp0" -m fill &
fi
# ... repeat for each monitor
```

Or simpler: just use `swaybg -i <wallpaper> -m fill` (all monitors same image).

### B2: greetd Restart Behavior

**Question:** Should greetd restart on nixos-rebuild?

**Decision:** No - `services.greetd.restart = false`

Rationale: Restarting greetd would kill the active session during rebuild.

**Note:** This is already set correctly in the old repo's module.nix but was not carried over. Need to add:

```nix
services.greetd.restart = false;
```

### B3: Niri User Services

**Question:** Should niri user services (waybar, swaybg, etc.) start at boot or with niri?

**Decision:** Start with niri session only.

**Implementation:** Already correct - services use `WantedBy = [ "niri.service" ]` and `PartOf = [ "niri.service" ]`.

### B4: KDE Apps in Niri

**Question:** How to ensure KDE apps (dolphin, kate) work correctly in niri?

**Decision:** Already handled by environment variables:
- `QT_QPA_PLATFORM = "wayland"` - Qt apps use Wayland
- Both portals available for file dialogs

**Note:** The old repo had `--platformtheme kde` hack for Qt6 apps. Check if still needed.

---

## Open Questions for User

### Q1: Portal Configuration
Do you approve Option A (session-specific portal routing)?

### Q2: Wallpaper Simplification for VM
Is it acceptable to use a single wallpaper for all monitors in vm-test, or should we implement proper monitor detection?

### Q3: greetd restart=false
Should we add `services.greetd.restart = false` to prevent session kill during rebuild?

### Q4: Desktop Entries
Skip wdisplays/clipboard-picker desktop entries for now?

---

## Design Summary

| Component | Decision | Status |
|-----------|----------|--------|
| XDG Portals | Session-specific routing (Option A) | **NEEDS FIX** |
| Wallpaper | Graceful fallback for missing monitors | **NEEDS FIX** |
| greetd restart | Add `restart = false` | **NEEDS FIX** |
| User services | Already correct (niri-lifecycle) | OK |
| KDE apps | Should work via env vars | NEEDS TEST |
| Desktop entries | Skip for now | OK |
| gtkgreet | Skip (using tuigreet) | OK |
| Preflight | Skip for now | OK |

---

## Phase 2 Complete

**Next:** Phase 3 - Implementation (apply fixes)
