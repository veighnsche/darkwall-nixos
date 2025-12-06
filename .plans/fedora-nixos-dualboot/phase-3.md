# Phase 3 — Implementation

> **TEAM_438: This document contains destructive disk operations.**
> Read the entire document before executing any commands.
> All "magic numbers" are examples derived from the specific disk layout below.

---

## Verified Facts (as of 2024-12-06)

| Item | Value | Source |
|------|-------|--------|
| Disk | `/dev/nvme0n1` | `lsblk` |
| Disk size | 1000 GB (931.5 GiB) | `parted print` |
| GitHub remote | `git@github.com:veighnsche/darkwall-nixos.git` | `git remote -v` |
| Flake output | `nixosConfigurations.blep` | `flake.nix` line 76 |
| EFI UUID | `2451-5874` | `blkid /dev/nvme0n1p1` |
| Fedora btrfs usage | 26 GB used of 929 GB | `df -h /` |
| GRUB + os-prober | Enabled in `hosts/blep/default.nix` | Lines 20-24 |

### Current Partition Layout

```
Number  Start     End       Size      Type   Label/Flags
1       1 MiB     630 MB    629 MB    vfat   EFI System Partition (boot, esp)
2       630 MB    2778 MB   2147 MB   ext4   Fedora /boot (bls_boot)
3       2778 MB   1000 GB   997 GB    btrfs  Fedora root (label: fedora)
```

### Target Partition Layout

| Part | Start | End | Size | Type | Purpose |
|------|-------|-----|------|------|---------|
| p1 | 1 MiB | 630 MB | 629 MB | vfat | EFI (unchanged) |
| p2 | 630 MB | 2778 MB | 2147 MB | ext4 | Fedora /boot (unchanged) |
| p3 | 2778 MB | **~103 GB** | **~100 GB** | btrfs | Fedora root (shrunk) |
| p4 | ~103 GB | ~984 GB | **~881 GB** | ext4 | NixOS root (new) |
| p5 | ~984 GB | 1000 GB | **~16 GB** | swap | NixOS swap (new) |

**How these numbers are derived:**
- `p3 end` = p3 start (2778 MB) + target Fedora size (100 GB) ≈ **102.8 GB**
- `p4 end` = disk size (1000 GB) - swap size (16 GB) ≈ **984 GB**
- `p5` = remaining space ≈ **16 GB**

⚠️ **These are examples.** You MUST verify with `parted print` and adjust.

---

## Prerequisites

- [ ] Secure Boot disabled in BIOS (required for kexec)
- [ ] At least 1 GB RAM available
- [ ] Config pushed to GitHub (you lose local disk access after kexec)

---

## Step 1: Push Config to GitHub

```bash
cd ~/Projects/darkwall-nixos
git add -A
git commit -m "Pre-install: prepare for blep deployment"
git push
```

**Verify:** `git log -1 --oneline` shows your commit.

---

## Step 2: kexec into NixOS Installer

```bash
# As root on Fedora:
sudo -i

# Download and run kexec bundle
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run

# After 6 seconds, system boots into NixOS installer
```

**If kexec fails:** Disable Secure Boot or use USB installer.

---

## Step 3: VERIFY Disk Layout (From NixOS Installer)

**⚠️ DO NOT SKIP THIS STEP.**

Once booted into NixOS installer:

```bash
# Check partition layout
sudo parted /dev/nvme0n1 print
```

**STOP if any of these are false:**
- [ ] p1 is ~600 MB vfat with `boot, esp` flags (EFI)
- [ ] p2 is ~2 GB ext4 with `bls_boot` flag (Fedora /boot)
- [ ] p3 is ~997 GB btrfs (Fedora root)
- [ ] No unexpected partitions (p4, p5, etc.)

**Record actual values:**
```
p2 end = _______ MB  (this becomes p3 start)
Disk size = _______ GB
```

---

## Step 4: VERIFY Fedora Usage Before Shrink

```bash
sudo mkdir -p /mnt/fedora
sudo mount /dev/nvme0n1p3 /mnt/fedora
df -h /mnt/fedora
```

**STOP if used space is NOT well below target size:**
- Target: 100 GB
- Safe threshold: < 70 GB used (leaves 30% headroom)
- Current (verified): 26 GB used ✓

```bash
# If safe, proceed. If not, abort and re-plan.
```

---

## Step 5: Shrink Fedora Btrfs

```bash
# Shrink filesystem to target size
sudo btrfs filesystem resize 100G /mnt/fedora

# Verify new size
df -h /mnt/fedora
# Should show ~100G total

# Unmount
sudo umount /mnt/fedora
```

---

## Step 6: Repartition Disk

**Calculate your boundaries first:**
```
p3_new_end = p3_start + 100 GB
           = 2778 MB + 100 GB
           ≈ 102.8 GB (use 103GB to be safe)

p4_end     = disk_size - swap_size
           = 1000 GB - 16 GB
           = 984 GB

p5         = remaining (984 GB to 100%)
```

```bash
sudo parted /dev/nvme0n1

# In parted (adjust numbers based on YOUR parted print output):
(parted) print                              # Verify current state
(parted) resizepart 3 103GB                 # Shrink p3 to ~100 GB
(parted) mkpart primary ext4 103GB 984GB    # NixOS root
(parted) mkpart primary linux-swap 984GB 100%  # Swap
(parted) print                              # Verify result
(parted) quit
```

**Verify with lsblk:**
```bash
lsblk /dev/nvme0n1
```

Expected:
```
nvme0n1p1   ~600M   (EFI, unchanged)
nvme0n1p2   ~2G     (Fedora /boot, unchanged)
nvme0n1p3   ~100G   (Fedora root, shrunk)
nvme0n1p4   ~881G   (NixOS root, new)
nvme0n1p5   ~16G    (swap, new)
```

---

## Step 7: Format New Partitions

```bash
# Format NixOS root with label
sudo mkfs.ext4 -L nixos /dev/nvme0n1p4

# Format swap with label
sudo mkswap -L swap /dev/nvme0n1p5

# ⚠️ DO NOT format p1, p2, p3 - they contain Fedora!
```

---

## Step 8: Mount Filesystems

```bash
# Mount NixOS root
sudo mount /dev/nvme0n1p4 /mnt

# Mount EFI partition (shared with Fedora)
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot

# Enable swap
sudo swapon /dev/nvme0n1p5

# Verify mounts
mount | grep /mnt
```

---

## Step 9: Clone Configuration

The flake's `hosts/blep/hardware-configuration.nix` is the **single source of truth**.
We do NOT use `nixos-generate-config` — the flake already has the correct config.

```bash
# Network should already be configured (kexec preserves it)
# If not: sudo systemctl start wpa_supplicant

# Install git in a nix-shell
nix-shell -p git

# Clone the flake (this IS your /etc/nixos)
git clone https://github.com/veighnsche/darkwall-nixos.git /mnt/etc/nixos
```

**Verify:**
```bash
ls /mnt/etc/nixos/hosts/blep/
# Should show: default.nix  hardware-configuration.nix
```

---

## Step 10: Verify Hardware Configuration

The flake uses labels (`nixos`, `swap`) and the existing EFI UUID.

```bash
# Get actual UUIDs for reference
blkid /dev/nvme0n1p1 /dev/nvme0n1p4 /dev/nvme0n1p5
```

**Check that `hosts/blep/hardware-configuration.nix` matches:**

```bash
cat /mnt/etc/nixos/hosts/blep/hardware-configuration.nix | grep -A2 'fileSystems\|swapDevices'
```

Expected (already configured):
- `/` → `/dev/disk/by-label/nixos` ✓
- `/boot` → `/dev/disk/by-uuid/2451-5874` ✓ (EFI UUID)
- swap → `/dev/disk/by-label/swap` ✓

**If EFI UUID differs**, edit the file:
```bash
nano /mnt/etc/nixos/hosts/blep/hardware-configuration.nix
# Update the UUID on the fileSystems."/boot" line
```

---

## Step 11: Install NixOS

```bash
cd /mnt/etc/nixos
sudo nixos-install --flake .#blep --no-root-passwd
```

This will:
- Build the NixOS system from the flake
- Install GRUB to the EFI partition
- Run os-prober to detect Fedora

---

## Step 12: Reboot

```bash
sudo reboot
```

**Expected GRUB menu:**
- NixOS (default)
- Fedora (detected by os-prober)

---

## Troubleshooting

### GRUB doesn't show Fedora

```bash
# After booting NixOS:
sudo os-prober
# Should output something like: /dev/nvme0n1p3:Fedora:...

# If it detects Fedora, rebuild:
sudo nixos-rebuild switch --flake /etc/nixos#blep
```

If os-prober finds nothing, check that:
- `boot.loader.grub.useOSProber = true;` is set (it is, in `hosts/blep/default.nix`)
- Fedora's btrfs is intact (`sudo mount /dev/nvme0n1p3 /mnt && ls /mnt`)

### Fedora won't boot after partition changes

Boot Fedora recovery or NixOS, then:
```bash
sudo mount /dev/nvme0n1p3 /mnt
cat /mnt/etc/fstab
# Check if UUIDs still match (they should, we didn't change them)
```

### kexec fails

Fall back to USB installer:
1. Download NixOS ISO
2. Use Ventoy or `dd` to create bootable USB
3. Boot from USB and continue from Step 3

---

## Config Dependencies (for reference)

The following NixOS options enable dual-boot GRUB:

```nix
# hosts/blep/default.nix lines 17-27
boot.loader = {
  systemd-boot.enable = false;
  grub = {
    enable = true;
    device = "nodev";      # EFI install, not MBR
    efiSupport = true;
    useOSProber = true;    # Detect Fedora
  };
  efi.canTouchEfiVariables = true;
};
```

The flake wires `hosts/blep` into `nixosConfigurations.blep`:

```nix
# flake.nix lines 75-81
blep = nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules = sharedModules ++ [
    ./hosts/blep
  ];
};
```

---

## Next Phase

Phase 4: Testing — Verify both OSes boot correctly.
