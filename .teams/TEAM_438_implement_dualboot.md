# TEAM_438: Implement Dual-Boot Plan

## Mission
Execute the Fedora + NixOS dual-boot installation plan.

## Plan Reference
- `.plans/fedora-nixos-dualboot/phase-3.md`

## Verified Facts
| Item | Value | Source |
|------|-------|--------|
| Disk | `/dev/nvme0n1` (1000 GB) | `parted print` |
| GitHub | `git@github.com:veighnsche/darkwall-nixos.git` | `git remote -v` |
| Flake output | `nixosConfigurations.blep` | `flake.nix:76` |
| EFI UUID | `2451-5874` | `blkid` |
| Fedora usage | 26 GB | `df -h /` |
| GRUB config | `hosts/blep/default.nix:20-24` | verified |
| Hardware config | `hosts/blep/hardware-configuration.nix` | verified |

## Doc Review (per ChatGPT feedback)

### Issues Fixed
1. ✅ **Hard-coded sizes** → Now explained as derived values with formulas
2. ✅ **No usage check before shrink** → Added Step 4 with 70% threshold
3. ✅ **nixos-generate-config confusion** → Removed; flake is single source of truth
4. ✅ **GitHub URL drift** → Verified: `veighnsche/darkwall-nixos`
5. ✅ **Partition identity assumptions** → Added Step 3 verification checklist
6. ✅ **GRUB/os-prober dependency** → Added Config Dependencies section

### Partition Calculations (corrected)
```
p3_new_end = 2778 MB + 100 GB ≈ 103 GB
p4_end     = 1000 GB - 16 GB  = 984 GB
p4_size    = 984 - 103        = 881 GB (not 815G as originally stated)
```

## Prerequisites Checklist
- [x] Config pushed to GitHub (commit 9d81c7f)
- [ ] Secure Boot disabled in BIOS
- [ ] kexec executed
- [ ] Partitions verified and created
- [ ] NixOS installed

## Current Step
Docs updated. Ready for user to execute kexec.

## Progress Log
- 2024-12-06: Team created, starting implementation
- 2024-12-06: Config pushed to GitHub (9d81c7f)
- 2024-12-06: Rewrote phase-3.md per ChatGPT review (6 issues fixed)
