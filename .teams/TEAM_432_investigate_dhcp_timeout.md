# TEAM_432: Investigate DHCP/Network Device Timeout

## Bug Report

**Symptom:** During VM boot, DHCP client starts but then a job for `/sys/subsystem/net/devices/enp1s0` times out (1min 9s / 1min 30s).

**Environment:** NixOS VM test configuration (darkwall-nixos)

## Investigation

### Phase 1 — Symptom Analysis

The boot log shows:
- `[OK] Started DHCP Client`
- `[***] A start job is running for /sys/subsystem/net/devices/enp1s0 (1min 9s / 1min 30s)`

This is a **conflict between two DHCP mechanisms**:
1. NetworkManager (enabled in `networking.nix`)
2. Per-interface DHCP (enabled in `hardware-configuration.nix`)

### Phase 2 — Root Cause

**File:** `hosts/vm-test/hardware-configuration.nix` line 23
```nix
networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
```

**File:** `modules/system/networking.nix` lines 6 and 9
```nix
networking.networkmanager.enable = true;
networking.useDHCP = lib.mkDefault false;
```

**Problem:** When NetworkManager is enabled, it handles DHCP itself. But `networking.interfaces.enp1s0.useDHCP = true` enables the **systemd-networkd** DHCP client for that interface, which:
1. Waits for the interface to appear in `/sys/subsystem/net/devices/`
2. Conflicts with NetworkManager trying to manage the same interface
3. Times out because NetworkManager has already claimed the interface

### Phase 3 — Fix

Remove the per-interface DHCP setting. NetworkManager will handle DHCP automatically.

## Status

- [x] Root cause identified
- [ ] Fix applied
- [ ] Tested
