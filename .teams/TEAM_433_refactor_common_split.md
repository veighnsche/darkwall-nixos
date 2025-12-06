# TEAM_433: Refactor common/ into base + NixOS-specific

## Objective

Split `home/common/` so:
- **Fedora standalone** can use shared config (Windsurf, XDG, mimeApps, shell)
- **NixOS** gets the full config including KDE apps

## Plan

1. Create `common/base.nix` — shared by ALL (XDG, mimeApps, darkwall-windsurf, shell-base)
2. Update `common/default.nix` — NixOS: imports base + kde-apps
3. Update `standalone.nix` — Fedora: imports base only (+ genericLinux settings)

## Progress

- [ ] Create base.nix
- [ ] Update default.nix
- [ ] Update standalone.nix
- [ ] Test build
