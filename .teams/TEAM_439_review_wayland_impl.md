# TEAM_439: Review of Wayland Desktop Implementation

## Review Target
Implementation by TEAM_426: wayland-desktop feature installation from old nixos repo.

## Phase 1: Implementation Status

**Status: WIP (Work in Progress)**

Evidence:
- TEAM_426 file lists unchecked TODOs: test build, verify session, test persistence
- No build verification performed (nix daemon unavailable on Fedora)
- Syntax-only validation done via `nix-instantiate --parse`

---

## Phase 2: Gap Analysis

### Implemented (from old repo)
- [x] Niri compositor enablement (`programs.niri.enable`)
- [x] System packages (waybar, swayidle, rofi, etc.)
- [x] XDG portals for wlroots
- [x] Environment variables
- [x] Home-manager services (mako, rofi, swaylock, cliphist)
- [x] Systemd user services (swaybg, waybar, swayidle, etc.)
- [x] Dotfiles copied (niri, waybar, rofi, swaylock)
- [x] greetd with auto-login

### Not Implemented (dropped from old repo)
- [ ] `gtkgreet.css` - not copied (greeter styling)
- [ ] `desktop-entries.nix` - wdisplays and clipboard-picker entries
- [ ] `preflight.nix` - niri config validation
- [ ] `environment.nix` as separate file (merged into main module)
- [ ] `feature.nix` metadata (not needed in simpler architecture)

### Unplanned Additions
- Auto-login for vince (hardcoded) - good addition per user request

---

## Phase 3: Code Quality Issues

### CRITICAL: XDG Portal Conflict

**kde.nix** sets:
```nix
xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
};
```

**wayland/default.nix** sets:
```nix
xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  config.niri = { ... };
};
```

**Problem:** Both modules define `xdg.portal` settings. NixOS will merge these, but:
- `extraPortals` will contain BOTH kde and gtk portals
- `wlr.enable` from wayland will be added
- This may cause portal conflicts at runtime

**Fix:** Use `lib.mkMerge` or consolidate portal config.

### CRITICAL: Environment Variable Collision

**kde.nix** sets:
```nix
environment.sessionVariables = {
  BROWSER = "firefox";
  DEFAULT_BROWSER = "firefox";
};
```

**wayland/default.nix** sets:
```nix
environment.sessionVariables = {
  MOZ_ENABLE_WAYLAND = "1";
  QT_QPA_PLATFORM = "wayland";
  # ...
};
```

**Problem:** These will merge (which is fine), but the wayland-specific vars will apply to KDE sessions too. This is actually correct behavior for Wayland KDE, so no action needed.

### MINOR: Team File Stale

**TEAM_426 file** says:
> "First login: user picks session (one-time)"

But greetd was updated to auto-login vince. File should be updated.

### MINOR: Hardcoded Monitor Config

Wallpaper script has hardcoded monitors: `DP-1`, `HDMI-A-2`, `HDMI-A-1`. This is machine-specific to blep and won't work on vm-test or other hosts.

---

## Phase 4: Architectural Assessment

### Rule 0 (Quality > Speed): PASS
- Clean module separation
- No hacks or shortcuts

### Rule 5 (Breaking Changes): PASS  
- greetd properly disables SDDM with `lib.mkForce`
- No compatibility shims

### Rule 6 (No Dead Code): PASS
- No unused code

### Rule 7 (Modular Refactoring): PARTIAL
- Good separation of system vs home config
- But portal config should be consolidated

### Duplication: MINOR ISSUE
- `xdg.portal.enable = true` set in both kde.nix and wayland/default.nix
- `programs.swaylock.settings` in wayland.nix duplicates some values from dotfiles/swaylock/config

---

## Phase 5: Direction Check

**Continue with fixes.** The implementation is on track but needs:

1. Fix portal configuration conflict
2. Update TEAM_426 file to reflect auto-login change
3. Consider making monitor config host-specific

---

## Phase 6: Recommendations

### Immediate Fixes Required

1. **Fix portal conflict** - Consolidate or use `lib.mkMerge`
2. **Update TEAM_426 docs** - Reflect auto-login change

### Optional Improvements

3. **Add gtkgreet.css** - For styled login fallback
4. **Move monitor config** - To host-specific or use dynamic detection
5. **Add desktop entries** - wdisplays, clipboard-picker

### Before Deploying

- [ ] Test build on NixOS: `nixos-rebuild build --flake .#blep`
- [ ] Verify no portal conflicts at runtime
- [ ] Test auto-login works
- [ ] Test logout → tuigreet fallback

---

## Handoff

Status: **Needs fixes before deployment**

Priority fixes:
1. Portal configuration conflict (CRITICAL)
2. Documentation update (MINOR)
