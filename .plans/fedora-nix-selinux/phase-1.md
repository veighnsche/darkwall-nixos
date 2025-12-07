# Phase 1: Fedora nix-daemon SELinux Fix

## Status: ✅ IMPLEMENTED by TEAM_443

## Problem

nix-daemon and nix sandbox fail on Fedora because SELinux blocks:
- Socket creation
- FIFO creation in build directories
- File operations in `/nix/var/nix/builds/`

## Solution: Pre-built SELinux Policy Module

**Location:** `scripts/fedora/nix-sandbox.pp`

### One-time Installation

```bash
sudo semodule -i scripts/fedora/nix-sandbox.pp
sudo systemctl restart nix-daemon
```

### Verify Installation

```bash
semodule -l | grep nix-sandbox  # Should show "nix-sandbox"
getenforce                       # Should show "Enforcing"
just home                        # Should work without errors
```

## What the Policy Allows

The policy (`scripts/fedora/nix-sandbox.te`) grants `init_t` (nix sandbox context):

- **fifo_file**: create, open, read, write, unlink, getattr on `default_t`
- **dir**: add_name, remove_name, write, read on `default_t`
- **file**: read, write, create, unlink, getattr, open on `default_t`
- **lnk_file**: read, getattr on `user_home_t`
- **dir/file**: operations on `snapperd_data_t` (for snapper integration)

## Regenerating the Policy

If you encounter new SELinux denials:

```bash
# Collect all denials
sudo ausearch -m avc -ts today --raw | sudo audit2allow -M nix-sandbox-new

# Review what it allows
cat nix-sandbox-new.te

# Install if acceptable
sudo semodule -i nix-sandbox-new.pp
```
