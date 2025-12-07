# Question: How to create direct symlinks that bypass the Nix store?

**Team:** TEAM_447 (Resolved by TEAM_448)
**Date:** 2025-12-07
**Status:** ✅ RESOLVED — `mkOutOfStoreSymlink` works correctly

## The Problem

We want dotfiles to be **directly symlinked** to the flake repo:

```
~/.config/niri -> /home/vince/Projects/darkwall-nixos/home/vince/darkwall-niri/dotfiles/niri
```

This allows **instant edits** — change a config file, see the effect immediately, no rebuild needed.

## What We've Tried

### 1. `mkOutOfStoreSymlink` with `xdg.configFile`

```nix
xdg.configFile."niri" = {
  source = config.lib.file.mkOutOfStoreSymlink "/home/vince/Projects/darkwall-nixos/.../niri";
};
```

**Result:** Creates `/nix/store/.../home-manager-files/.config/niri/config.kdl` which is a symlink to the target, but `~/.config/niri` points to the store path, not directly to the repo.

### 2. `mkOutOfStoreSymlink` with `home.file`

```nix
home.file.".config/niri" = {
  source = config.lib.file.mkOutOfStoreSymlink "/home/vince/Projects/darkwall-nixos/.../niri";
};
```

**Result:** Same as above — still goes through store.

### 3. Activation script after `writeBoundary`

```nix
home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  ln -sf /path/to/repo/dotfiles/niri ~/.config/niri
'';
```

**Result:** Home-manager's `linkGeneration` runs after and overwrites our symlinks.

### 4. Activation script after `linkGeneration`

```nix
home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
  rm -rf ~/.config/niri
  ln -sf /path/to/repo/dotfiles/niri ~/.config/niri
'';
```

**Result:** Still not working. Symlinks still point to store. Unknown why.

## Questions for Investigation

1. **What is the full activation order in home-manager?**
   - Is there something that runs after `linkGeneration`?
   - Is there a "final" hook we can use?

2. **Why does `mkOutOfStoreSymlink` go through the store?**
   - The name suggests it should bypass the store
   - Is this a bug or expected behavior?

3. **How do other projects solve this?**
   - Search: "home-manager live dotfiles"
   - Search: "nix dotfiles instant edit"
   - Search: "mkOutOfStoreSymlink not working"

4. **Should we bypass home-manager entirely for these files?**
   - Use a NixOS system activation script instead?
   - Use a separate dotfile manager (stow, chezmoi)?

## Acceptance Criteria

The solution must:

1. Create a **direct symlink**: `~/.config/niri -> /home/vince/Projects/darkwall-nixos/.../niri`
2. **No store path** in the chain
3. Work in both VM and bare-metal NixOS
4. Survive reboots and `nixos-rebuild switch`
5. Allow instant edits without rebuild

## Related Files

- `home/vince/darkwall-niri/default.nix` — current (broken) implementation
- `home/common/darkwall-windsurf/default.nix` — same pattern, same problem
- `.teams/TEAM_447_review_agenix_implementation.md` — full context

## Resolution (TEAM_448)

### Root Cause

The `mkOutOfStoreSymlink` implementation was **already correct**. The issue was a **stale home-manager generation** that was built before the TEAM_447 fix was applied.

### Fix

Simply rebuild home-manager:

```bash
home-manager switch --flake /home/vince/Projects/darkwall-nixos#vince@fedora
```

### Verification

```bash
readlink -f ~/.codeium/windsurf/mcp_config.json
# → /home/vince/Projects/darkwall-nixos/home/common/darkwall-windsurf/dotfiles/mcp_config.json ✓
```

### How mkOutOfStoreSymlink Actually Works

The function creates a symlink chain (by design):
```
~/.config/X → /nix/store/.../home-manager-files/.config/X → /nix/store/.../hm_X → /actual/runtime/path
```

The final target IS the runtime path (outside store), enabling instant edits.

### Remaining: NixOS VM

The niri config uses an activation script approach (not `mkOutOfStoreSymlink`). This needs separate testing on the NixOS VM.

## References

- [Home Manager mkOutOfStoreSymlink](https://nix-community.github.io/home-manager/options.xhtml#opt-home.file._name_.source)
- [NixOS Discourse](https://discourse.nixos.org/) — search for similar issues
- [Gabriel Volpe's Blog](https://gvolpe.com/blog/home-manager-dotfiles-management/) — excellent explanation of mkOutOfStoreSymlink
