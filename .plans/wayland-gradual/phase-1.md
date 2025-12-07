# Phase 1: Clean Slate - Remove All Wayland Additions

## Goal
Remove all wayland/niri additions and verify VM boots with just KDE.

## Files to Remove

### Delete entirely:
- `modules/desktop/wayland/` (directory)
- `modules/desktop/greetd.nix`
- `home/vince/wayland.nix`
- `home/vince/wayland/` (directory)

### Revert changes:
- `modules/desktop/default.nix` - remove wayland and greetd imports
- `modules/desktop/kde.nix` - revert portal config to original
- `home/vince/default.nix` - remove wayland.nix import

## Verification
```bash
git add -A && just vm-run
```

Expected: VM boots to KDE Plasma desktop (SDDM login → Plasma)

## Exit Criteria
- [ ] All wayland files removed
- [ ] VM boots successfully
- [ ] KDE Plasma desktop works
