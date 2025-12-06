# Fedora + NixOS Dual-Boot Plan

> **Goal:** Install NixOS alongside Fedora 43 KDE without USB installer

## Summary

| OS | Partition | Size | Purpose |
|----|-----------|------|---------|
| Shared | nvme0n1p1 | 600M | EFI boot |
| Fedora | nvme0n1p2 | 2G | /boot |
| Fedora | nvme0n1p3 | 100G | / and /home (fallback ~10%) |
| NixOS | nvme0n1p4 | 815G | / (primary) |
| NixOS | nvme0n1p5 | 16G | swap |

## Approach

1. **kexec** from running Fedora into NixOS minimal installer
2. **Repartition** disk (shrink Fedora btrfs, create NixOS partitions)
3. **Install** NixOS using existing flake config
4. **GRUB** with os-prober detects both OSes

## Phases

| Phase | File | Status |
|-------|------|--------|
| 1. Discovery | [phase-1.md](./phase-1.md) | ✅ Complete |
| 2. Design | [phase-2.md](./phase-2.md) | ✅ Complete |
| 3. Implementation | [phase-3.md](./phase-3.md) | ✅ Reviewed, ready to execute |
| 4. Testing | - | 🔲 Pending |
| 5. Polish | - | 🔲 Pending |

## User Decisions

1. **Fedora space:** 100G ✓
2. **NixOS filesystem:** ext4 ✓
3. **Backup:** Handled by workstation later ✓

## Quick Start

Once confirmed, follow [phase-3.md](./phase-3.md) step by step.

## Team
- **TEAM_436** — see [team file](../../.teams/TEAM_436_fedora_nixos_dualboot.md)
