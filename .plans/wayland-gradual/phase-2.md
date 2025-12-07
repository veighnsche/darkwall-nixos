# Phase 2: Add Niri Compositor Only

## Goal
Add just the niri compositor package - no services, no greetd, no config.

## Changes

### Step 1: Add niri package to system
In `modules/desktop/kde.nix` (or create minimal `modules/desktop/niri.nix`):

```nix
programs.niri.enable = true;
```

That's it. Just enable niri. This:
- Adds niri package
- Creates niri.desktop session file
- Allows selecting niri from SDDM

## Verification
```bash
git add -A && just vm-run
```

1. VM boots to SDDM
2. Can select "niri" session from dropdown
3. Niri starts (may be blank/minimal - that's OK)
4. Can switch back to Plasma

## Exit Criteria
- [ ] `programs.niri.enable = true` added
- [ ] VM boots to SDDM
- [ ] Niri session appears in SDDM dropdown
- [ ] Can log into niri (even if minimal)
