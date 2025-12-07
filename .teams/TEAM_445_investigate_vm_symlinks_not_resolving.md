# TEAM_445: Investigate VM symlinks not resolving

## Bug Report

**Symptom:** In the VM, niri config is not found at `~/.config/niri/config.kdl`
- Niri shows "Failed to parse the config file"
- `niri validate` says "no config file found"
- Zsh shows new user wizard (no .zshrc)

**Expected:** Symlinks should point to flake repo dotfiles and resolve correctly

**Root cause hypothesis:** The VM doesn't have the host path `/home/vince/Projects/darkwall-nixos` mounted, so symlinks created by `mkOutOfStoreSymlink` point to non-existent paths.

## Investigation

### Phase 1: Understand the symptom

The symlink strategy uses `mkOutOfStoreSymlink` which creates symlinks like:
```
~/.config/niri -> /home/vince/Projects/darkwall-nixos/home/vince/darkwall-niri/dotfiles/niri
```

This path exists on the Fedora host but NOT inside the VM.

### Phase 2: Hypotheses

1. **VM needs shared folder mount** - The flake directory needs to be mounted into the VM at the same path
2. **flakePath is wrong in VM context** - Maybe flakePath resolves differently in VM builds

### Phase 3: Check VM configuration

Need to check:
1. How the VM is configured
2. Whether shared folders are set up
3. What flakePath resolves to

## Status

- [x] Check VM host configuration
- [x] Check if shared folder is configured - **NOT configured, this was the bug**
- [ ] Verify fix works

## Root Cause

The VM was missing `sharedDirectories` configuration. The symlinks created by `mkOutOfStoreSymlink` point to `/home/vince/Projects/darkwall-nixos/...` which exists on the host but not in the VM.

## Fix

Added to `hosts/vm-test/default.nix`:
```nix
sharedDirectories = {
  flake-repo = {
    source = "/home/vince/Projects/darkwall-nixos";
    target = "/home/vince/Projects/darkwall-nixos";
  };
};
```

This mounts the flake directory into the VM at the same path, so symlinks resolve correctly.
