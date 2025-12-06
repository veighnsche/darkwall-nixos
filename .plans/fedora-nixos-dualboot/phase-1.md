# Phase 1 — Discovery

## Feature Summary
Install NixOS alongside Fedora 43 KDE without USB installer, where:
- **Fedora** = 20% fallback (~200G) for recovering broken NixOS builds
- **NixOS** = Primary daily driver (~700G)

## Problem Statement
- USB installers are inconvenient for iterative NixOS development
- Need a safety net when NixOS builds fail
- Want to preserve Fedora's known-working KDE environment

## Success Criteria
1. Can boot into both Fedora and NixOS from GRUB menu
2. NixOS uses the existing `darkwall-nixos` flake configuration
3. Fedora remains functional with all current data intact
4. Shared EFI partition works for both OSes

## Current State Analysis

### Disk Layout
```
nvme0n1     931.5G
├─nvme0n1p1   600M vfat  /boot/efi  (EFI System Partition)
├─nvme0n1p2     2G ext4  /boot      (Fedora /boot)
└─nvme0n1p3 928.9G btrfs /,/home    (Fedora root, 26G used, 902G free)
```

### Key Observations
- **Btrfs** can be shrunk online (but requires careful handling)
- **600M EFI** is sufficient for both bootloaders
- **902G free** gives ample room for NixOS

### Installation Methods (No USB)

| Method | Pros | Cons |
|--------|------|------|
| **nixos-anywhere** | Automated, uses kexec | Requires SSH, designed for remote |
| **kexec into installer** | Boots NixOS installer from Fedora | Must partition first |
| **Manual chroot** | Full control | Complex, error-prone |

**Recommended:** kexec approach - download NixOS installer kernel/initrd, boot it via kexec, install to prepared partitions.

## Codebase Reconnaissance

### Files to Update
- `hosts/blep/hardware-configuration.nix` - Partition UUIDs after creation
- `hosts/blep/default.nix` - Already configured for dual-boot GRUB

### Existing Config Already Handles
- GRUB with os-prober (detects Fedora) ✓
- Shared EFI partition ✓
- Intel hardware support ✓

## Constraints
1. **Cannot lose Fedora data** - Backup before shrinking
2. **Must shrink btrfs safely** - Requires unmounting, use live env or kexec
3. **Fedora keeps its own /boot** - Don't touch nvme0n1p2
4. **Share EFI only** - Both bootloaders coexist in /boot/efi

## Open Questions (Few Expected Here)
- Q1: How much space for Fedora? → Default 200G (can adjust)
- Q2: Btrfs or ext4 for NixOS? → ext4 (simpler, ZFS later if needed)

## Next Phase
Proceed to Phase 2: Design the partitioning and installation workflow.
