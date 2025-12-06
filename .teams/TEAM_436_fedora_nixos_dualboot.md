# TEAM_436: Fedora + NixOS Dual-Boot Setup

## Mission
Set up dual-boot NixOS alongside existing Fedora 43 KDE without USB installer.

## Context
- **Current OS:** Fedora 43 KDE with Nix + home-manager
- **Goal:** Fedora as 20% fallback, NixOS as primary
- **Constraint:** No USB ISO - install from running Fedora

## Disk Layout (current)
| Partition | Size | Type | Mount | Purpose |
|-----------|------|------|-------|---------|
| nvme0n1p1 | 600M | vfat | /boot/efi | Shared EFI |
| nvme0n1p2 | 2G | ext4 | /boot | Fedora boot |
| nvme0n1p3 | 929G | btrfs | /, /home | Fedora root (26G used) |

## Planned Layout
| Partition | Size | Type | Label | Purpose |
|-----------|------|------|-------|---------|
| nvme0n1p1 | 600M | vfat | - | Shared EFI (unchanged) |
| nvme0n1p2 | 2G | ext4 | - | Fedora boot (unchanged) |
| nvme0n1p3 | 100G | btrfs | fedora | Fedora root + home |
| nvme0n1p4 | 815G | ext4 | nixos | NixOS root |
| nvme0n1p5 | 16G | swap | swap | NixOS swap |

## Status
- [x] Team registered
- [x] Phase 1: Discovery
- [x] Phase 2: Design
- [x] Phase 3: Implementation (ready to execute)
- [ ] Phase 4: Testing
- [ ] Phase 5: Polish

## Progress Log
- 2024-12-06: Team created, analyzed disk layout
- 2024-12-06: TEAM_437 reviewed plan, updated to 100G Fedora, simplified kexec approach
