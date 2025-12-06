# Phase 2 — Design

## Overview
Install NixOS via kexec from running Fedora. This avoids USB by booting the NixOS installer kernel directly.

## Target Partition Layout

```
nvme0n1 (931.5G NVMe)
├── nvme0n1p1   600M  vfat   EFI    /boot/efi  (shared, unchanged)
├── nvme0n1p2     2G  ext4   -      -          (Fedora /boot, unchanged)
├── nvme0n1p3  100G  btrfs  fedora /,/home    (Fedora, shrunk from 929G)
├── nvme0n1p4  815G  ext4   nixos  /          (NixOS root)
└── nvme0n1p5   16G  swap   swap   [SWAP]     (NixOS swap)
```

## Installation Workflow

### Step 1: Backup (CRITICAL)
```bash
# Backup important data before touching partitions
tar -czvf ~/fedora-backup.tar.gz ~/Documents ~/Projects ~/.config
# Or use external drive
```

### Step 2: Shrink Btrfs from Live Environment
Btrfs online shrink is risky. Safer: boot into Fedora live USB or use kexec to NixOS installer first.

**Option A: Fedora Live USB (safest)**
```bash
# From live env:
btrfs filesystem resize 200G /mnt/fedora
```

**Option B: Boot NixOS Installer via kexec (no USB)**
```bash
# Download NixOS installer kernel/initrd
curl -LO https://channels.nixos.org/nixos-24.05/latest-nixos-minimal-x86_64-linux.iso
# Extract kernel/initrd (or use kexec-based installer)
```

### Step 3: Create NixOS Partitions
From installer environment:
```bash
# Create new partitions in freed space
fdisk /dev/nvme0n1
# n -> p4 -> +713G (nixos)
# n -> p5 -> +16G (swap)
# t -> 4 -> 83 (Linux)
# t -> 5 -> 82 (swap)
# w

# Format
mkfs.ext4 -L nixos /dev/nvme0n1p4
mkswap -L swap /dev/nvme0n1p5

# Mount
mount /dev/nvme0n1p4 /mnt
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot  # Shared EFI
swapon /dev/nvme0n1p5
```

### Step 4: Install NixOS
```bash
# Clone config
nix-shell -p git
git clone https://github.com/vince/darkwall-nixos /mnt/etc/nixos
cd /mnt/etc/nixos

# Update hardware-configuration.nix with actual UUIDs
nixos-generate-config --root /mnt --show-hardware-config

# Install
nixos-install --flake .#blep
```

### Step 5: Configure Bootloader
GRUB with os-prober will detect Fedora:
```nix
# hosts/blep/default.nix (already configured)
boot.loader.grub.useOSProber = true;
```

## Behavioral Decisions

### Q1: What happens if btrfs shrink fails?
**Answer:** Abort. Do not proceed. Restore from backup if needed.

### Q2: Which bootloader owns EFI?
**Answer:** NixOS GRUB. It detects Fedora via os-prober. Fedora's GRUB becomes secondary.

### Q3: Can we share /home?
**Answer:** No. Separate /home per OS avoids config conflicts. NixOS uses /home on its ext4.

### Q4: What if NixOS build fails during install?
**Answer:** Reboot to Fedora (hold Shift for GRUB menu if needed), fix config, try again.

## kexec Approach (No USB)

Using [nix-community/nixos-images](https://github.com/nix-community/nixos-images) kexec tarball:

```bash
# On running Fedora (as root):
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run
```

**What happens:**
1. Downloads pre-built NixOS kexec bundle (~500MB)
2. 6-second delay, then boots into NixOS installer
3. Runs entirely in RAM - all disks are free to repartition
4. Preserves SSH keys and network config

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Data loss during shrink | Full backup first |
| kexec fails | Fall back to USB installer |
| GRUB doesn't detect Fedora | Manually add entry |
| Wrong UUIDs in config | Re-generate hardware-configuration.nix |

## Answers from USER

1. **Fedora space:** 100G
2. **NixOS filesystem:** ext4
3. **Backup:** Skip - handled by workstation later

## Next Phase
After questions answered, proceed to Phase 3: Implementation with exact commands.
