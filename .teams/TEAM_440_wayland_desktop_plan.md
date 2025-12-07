# TEAM_440: Wayland Desktop Feature Plan

## Summary
Creating a comprehensive plan for the wayland-desktop feature installation from the old nixos repo.

## Context
- TEAM_426 did initial implementation
- TEAM_439 reviewed and found issues requiring planning before deployment

## Current Status
Planning phase - creating feature plan before `just vm-run` testing.

## Issues to Address (from TEAM_439 review)
1. **CRITICAL:** XDG portal conflict between kde.nix and wayland/default.nix
2. **GAP:** Missing gtkgreet.css (greeter styling)
3. **GAP:** Missing desktop-entries (wdisplays, clipboard-picker)
4. **GAP:** Missing preflight validation (niri config check)
5. **MINOR:** Hardcoded monitor config (blep-specific)
6. **MINOR:** Stale TEAM_426 documentation

## Planning Artifacts
- `.plans/wayland-desktop/phase-1.md` - Discovery (current state analysis)
- `.plans/wayland-desktop/phase-2.md` - Design (behavioral decisions)
- `.plans/wayland-desktop/phase-3.md` - Implementation fixes
- `.plans/wayland-desktop/phase-4.md` - Testing and validation
