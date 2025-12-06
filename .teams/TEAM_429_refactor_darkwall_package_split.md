# TEAM_429: Refactor - Split darkwall-windsurf Package

## Date: 2025-12-06

## Status: PLANNING

---

## Summary

Refactor `darkwall-windsurf` to properly separate concerns:
- **Package**: Binary, icons, desktop entry (immutable, in nix store)
- **Home-manager**: Dotfiles symlinks (mutable, points to repo)

## Problem Statement

Current implementation bakes dotfiles INTO the package, requiring rebuild on every dotfile change. This is wrong because:
1. Nix packages are immutable - dotfiles in store can't change
2. Even with runtime symlinks, they point to store paths
3. Violates the principle: packages = binaries, home-manager = user config

## Success Criteria

1. Edit `packages/darkwall-windsurf/dotfiles/foo.md` → change is instant (no rebuild)
2. Package only contains: binary, icons, desktop entries
3. Home-manager manages all dotfile symlinks via `mkOutOfStoreSymlink`
4. Clear separation of concerns

## Plan Location

`.plans/darkwall-package-refactor/`

## Progress

- [ ] Phase 1: Discovery and Safeguards
- [ ] Phase 2: Structural Extraction
- [ ] Phase 3: Migration
- [ ] Phase 4: Cleanup
- [ ] Phase 5: Hardening and Handoff
