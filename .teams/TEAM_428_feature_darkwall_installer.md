# TEAM_428: Feature Plan - darkwall-installer

## Date: 2025-12-06

## Status: PLANNING

---

## Summary

Create a shared `darkwall-installer` abstraction that provides a consistent installation process for all `darkwall-*` packages.

## Problem Statement

Currently, each `darkwall-*` package would need to duplicate:
1. The dotfiles installation logic (copy-if-newer pattern)
2. The wrapper script generation
3. The directory structure conventions

This violates DRY and makes it hard to maintain consistency across packages.

## Proposed Solution

Create a Nix library function `mkDarkwallPackage` that:
1. Enforces a consistent package structure
2. Provides a shared dotfiles installer
3. Generates wrapper scripts with the installation hook

## Plan Location

`.plans/darkwall-installer/`

## Progress

- [x] Cleaned up darkwall-windsurf to use file imports
- [ ] Phase 1: Discovery
- [ ] Phase 2: Design
- [ ] Phase 3: Implementation
- [ ] Phase 4: Integration
- [ ] Phase 5: Polish

## Handoff Notes

See `.plans/darkwall-installer/phase-1.md` for the full plan.
