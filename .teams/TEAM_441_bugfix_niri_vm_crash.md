# TEAM_441: Bugfix - Niri VM Crash + Fedora nix-daemon

## Bug 1: Niri VM Crash

**Error:** "Calling import-environment without a list of variable names is deprecated"

**Location:** `home/vince/wayland/dotfiles/niri/config.kdl`

**Root Cause:** The niri config has an `environment { }` block that uses deprecated syntax.

**Fix:** Update niri config to use explicit variable list or remove the block.

---

## Bug 2: Fedora nix-daemon SELinux

**Error:** SELinux blocks nix-daemon from creating socket on boot.

**Root Cause:** `/nix` has wrong SELinux context (`default_t` instead of proper context).

**Fix:** Create SELinux policy module or set proper context for `/nix`.

---

## Status

- [ ] Fix niri config deprecated syntax
- [ ] Fix Fedora SELinux for nix-daemon
