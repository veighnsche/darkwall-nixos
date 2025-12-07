# TEAM_447: Review Agenix Implementation

## Purpose

Review the agenix secrets + flake bootstrap implementation against user requirements.

## User Requirements

| # | Requirement | Status |
|---|-------------|--------|
| 1 | Copy `Projects/darkwall-nixos` from Fedora to all NixOS machines | ✓ Implemented |
| 2 | SSH key tied to vince on all machines | ✓ Implemented |
| 3 | Git remote configured for push access | ✓ Implemented |
| 4 | Dotfiles symlinked to expected locations | ✓ **Fixed on Fedora** (TEAM_448) — NixOS VM needs testing |

## Review Status

- [x] Phase 1: Implementation Status — Complete
- [x] Phase 2: Gap Analysis — Critical gap found
- [ ] Phase 3: Code Quality — **BLOCKED**
- [ ] Phase 4: Architectural Assessment — **BLOCKED**
- [ ] Phase 5: Direction Check — **BLOCKED**

## Critical Issue: Dotfile Symlinks Not Working

### The Goal

User wants dotfiles (niri, waybar, rofi configs) to be **directly symlinked** to the repo:
```
~/.config/niri -> /home/vince/Projects/darkwall-nixos/home/vince/darkwall-niri/dotfiles/niri
```

This allows **instant edits** without rebuilding NixOS.

### What We Tried (All Failed)

| Attempt | Approach | Result |
|---------|----------|--------|
| 1 | `xdg.configFile` + `mkOutOfStoreSymlink` | Symlinks go through `/nix/store/.../home-manager-files/` |
| 2 | `home.file` + `mkOutOfStoreSymlink` | Same — still goes through store |
| 3 | `home.activation` script after `writeBoundary` | Home-manager's `linkGeneration` runs after and overwrites |
| 4 | `home.activation` script after `linkGeneration` | **Still not working** — symlinks still point to store |

### Current State

- The repo IS copied to `~/Projects/darkwall-nixos` ✓
- The shared folder IS mounted in VM ✓
- The files ARE accessible at `~/Projects/darkwall-nixos/...` ✓
- BUT `~/.config/niri` still points to `/nix/store/.../home-manager-files/.config/niri` ✗

### Root Cause (Hypothesis)

Home-manager's symlink mechanism is fundamentally incompatible with our goal. Even `mkOutOfStoreSymlink` creates a store derivation that contains the symlink, rather than creating the symlink directly.

The activation script approach should work but something is overriding it or it's not running in the right order.

## Needs Fresh Investigation

A future team should:

1. **Investigate how home-manager's link generation actually works**
   - What is `linkGeneration`?
   - What runs after it?
   - Why doesn't our activation script override persist?

2. **Research how others solve this problem**
   - Search NixOS discourse/GitHub for "mkOutOfStoreSymlink not working"
   - Look for alternative approaches to live-editable dotfiles

3. **Consider alternatives**
   - System activation script instead of home-manager?
   - Impermanence module?
   - Just don't use home-manager for these specific files?

## Handoff

- [x] Project builds cleanly
- [x] Agenix secrets working
- [x] Flake bootstrap working
- [ ] **Dotfile symlinks NOT working — needs dedicated investigation**

## Files Modified (May Need Revert)

- `home/vince/darkwall-niri/default.nix` — multiple attempts, currently uses activation script
- `home/common/darkwall-windsurf/default.nix` — changed `flakePath` to hardcoded path
