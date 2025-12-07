# TEAM_448: Investigate Dotfile Symlinks Bypassing Store

## Purpose

Investigate why direct symlinks to the flake repo aren't working.

## Symptom

**Expected:** `~/.config/niri -> /home/vince/Projects/darkwall-nixos/.../niri`  
**Actual:** `~/.config/niri -> /nix/store/.../home-manager-files/.config/niri -> /nix/store/.../source/...`

## Investigation Status

- [x] Phase 1: Understand the Symptom
- [x] Phase 2: Form Hypotheses
- [x] Phase 3: Test Hypotheses
- [x] Phase 4: Root Cause
- [x] Phase 5: Decision — **FIXED**

## Root Cause

The `mkOutOfStoreSymlink` implementation was **already correct**. The issue was that the active home-manager generation was **stale** (built before TEAM_447's fix was applied).

### How mkOutOfStoreSymlink Works

```nix
lib.file.mkOutOfStoreSymlink = path:
  let
    pathStr = toString path;
    name = hm.strings.storeFileName (baseNameOf pathStr);
  in
    pkgs.runCommandLocal name {} ''ln -s ${escapeShellArg pathStr} $out'';
```

It creates a store derivation that is a **symlink to an absolute path**. The chain is:
```
~/.config/X → /nix/store/.../home-manager-files/.config/X → /nix/store/.../hm_X → /actual/path
```

### Evidence

1. Listed all `*-hm_mcp_config.json` derivations in store
2. Found ONE correct derivation: `/nix/store/r7d8xd23nnd0421y1lvynpy86r9x4syc-hm_mcp_config.json → /home/vince/Projects/darkwall-nixos/...`
3. Evaluated current flake: produces the correct derivation
4. Active generation: used an older derivation pointing to store source

### Fix Applied

```bash
home-manager switch --flake /home/vince/Projects/darkwall-nixos#vince@fedora
```

### Verification

```bash
readlink -f ~/.codeium/windsurf/mcp_config.json
# → /home/vince/Projects/darkwall-nixos/home/common/darkwall-windsurf/dotfiles/mcp_config.json ✓
```

## Remaining Work — COMPLETED

All symlinks now work:
- **Fedora**: `mkOutOfStoreSymlink` works after `home-manager switch`
- **NixOS VM**: `mkOutOfStoreSymlink` works after `nixos-rebuild test`

Both approaches use the same mechanism — the key is using absolute string paths and rebuilding.

## Additional Fixes Made

### Justfile VM Workflow
- `vm-run-fresh`: Builds VM, starts it, rebuilds inside to ensure fresh state
- `vm-rebuild`: Rebuilds inside running VM
- `vm-stop`: Stops VM gracefully
- VM result symlink moved to `/tmp/darkwall-vm-result` (outside shared folder)
- SSH uses `-o UserKnownHostsFile=/dev/null` (VM host key changes on fresh boot)
- Uses `nixos-rebuild test` instead of `switch` (avoids GRUB errors in running VM)

### Git Safe Directory
- Added system-wide `/etc/gitconfig` with `safe.directory` for shared folder
- Added to home-manager git config too

### Gitignore
- Added `result` and `*.qcow2` to prevent shared folder symlink issues

## Known Issues (For Future Teams)

1. **Agenix errors in fresh VM**: Expected — no host key to decrypt secrets. Set up agenix properly.
2. **Wayland env vars missing**: windsurf/electron apps need `NIXOS_OZONE_WL=1` and other Wayland vars.

## Handoff

- [x] Root cause identified
- [x] Fix verified on Fedora
- [x] Fix verified on NixOS VM
- [x] Team file updated
- [x] Justfile improved with proper VM workflow
