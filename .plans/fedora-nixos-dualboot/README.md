# Fedora + NixOS Dual-Boot Plan

> **Goal:** Install NixOS alongside Fedora 43 KDE without USB installer

## Summary

| OS | Partition | Size | Purpose |
|----|-----------|------|---------|
| Shared | nvme0n1p1 | ~600M | EFI boot |
| Fedora | nvme0n1p2 | ~2G | /boot |
| Fedora | nvme0n1p3 | **~100G** | / and /home (fallback) |
| NixOS | nvme0n1p4 | **~881G** | / (primary) |
| NixOS | nvme0n1p5 | **~16G** | swap |

> ⚠️ Sizes are approximate. See [phase-3.md](./phase-3.md) for exact calculations.

## Verified Facts

| Item | Value |
|------|-------|
| Disk | `/dev/nvme0n1` (1000 GB) |
| GitHub | `git@github.com:veighnsche/darkwall-nixos.git` |
| Flake output | `nixosConfigurations.blep` |
| EFI UUID | `2451-5874` |
| Fedora usage | 26 GB (safe to shrink to 100G) |

## Approach

1. **kexec** from running Fedora into NixOS minimal installer
2. **Verify** disk layout and Fedora usage before any destructive ops
3. **Shrink** Fedora btrfs, then **repartition**
4. **Install** NixOS using existing flake config
5. **GRUB** with os-prober detects both OSes

## Phases

| Phase | File | Status |
|-------|------|--------|
| 1. Discovery | [phase-1.md](./phase-1.md) | ✅ Complete |
| 2. Design | [phase-2.md](./phase-2.md) | ✅ Complete |
| 3. Implementation | [phase-3.md](./phase-3.md) | ✅ Reviewed, ready to execute |
| 4. Testing | - | 🔲 Pending |
| 5. Polish | - | 🔲 Pending |

## User Decisions

1. **Fedora space:** ~100G ✓
2. **NixOS filesystem:** ext4 ✓
3. **Backup:** Handled by workstation later ✓

## Before You Start

Read [phase-3.md](./phase-3.md) **completely** before executing any commands.

Key verification steps:
- [ ] `parted print` matches expected layout
- [ ] `df -h` shows Fedora usage < 70 GB
- [ ] `hosts/blep/hardware-configuration.nix` exists in flake
- [ ] EFI UUID in config matches actual disk

## Team
- **TEAM_436** — Planning
- **TEAM_437** — Review
- **TEAM_438** — Implementation
