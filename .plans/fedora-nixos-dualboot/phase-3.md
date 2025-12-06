# Phase 3 — Implementation

## Prerequisites
- [ ] Secure Boot disabled in BIOS
- [ ] At least 1GB RAM available
- [ ] Push `darkwall-nixos` to GitHub (needed after kexec)

---

## Step 1: Push Config to GitHub

```bash
cd ~/Projects/darkwall-nixos
git add -A
git commit -m "Pre-install: prepare for blep deployment"
git push
```

---

## Step 2: kexec into NixOS Installer

```bash
# As root on Fedora:
sudo -i

# Download and run kexec bundle (single command)
curl -L https://github.com/nix-community/nixos-images/releases/latest/download/nixos-kexec-installer-noninteractive-x86_64-linux.tar.gz | tar -xzf- -C /root
/root/kexec/run

# After 6 seconds, system boots into NixOS installer
# All disks become available for repartitioning
```

**If kexec fails:** Disable Secure Boot or use USB installer.

---

## Step 3: Shrink Fedora Btrfs (From NixOS Installer)

Once booted into NixOS installer:

```bash
# Check current layout
lsblk
# Expected: nvme0n1p3 is ~929G btrfs

# Mount Fedora btrfs to shrink it
sudo mkdir -p /mnt/fedora
sudo mount /dev/nvme0n1p3 /mnt/fedora

# Shrink btrfs filesystem to 100G (must be smaller than target partition)
sudo btrfs filesystem resize 100G /mnt/fedora

# Verify new size
df -h /mnt/fedora
# Should show ~100G

# Unmount
sudo umount /mnt/fedora
```

---

## Step 4: Repartition Disk

```bash
# Use parted (better for resizing than fdisk)
sudo parted /dev/nvme0n1

# In parted:
(parted) print                    # View current layout
(parted) resizepart 3 102.6GB     # Shrink p3 to 100G (600M + 2G + 100G = 102.6G end)
(parted) mkpart primary ext4 102.6GB 917.5GB   # NixOS root (~815G)
(parted) mkpart primary linux-swap 917.5GB 100%  # Swap (~16G)
(parted) print                    # Verify
(parted) quit

# Verify with lsblk
lsblk
```

**Expected result:**
```
nvme0n1p1   600M  EFI (unchanged)
nvme0n1p2     2G  Fedora /boot (unchanged)
nvme0n1p3   100G  Fedora root (shrunk)
nvme0n1p4   815G  NixOS root (new)
nvme0n1p5    16G  swap (new)
```

---

## Step 5: Format New Partitions

```bash
# Format NixOS root
sudo mkfs.ext4 -L nixos /dev/nvme0n1p4

# Format swap
sudo mkswap -L swap /dev/nvme0n1p5

# DO NOT format p1, p2, p3 - they contain Fedora!
```

---

## Step 6: Mount Filesystems

```bash
# Mount NixOS root
sudo mount /dev/nvme0n1p4 /mnt

# Mount EFI partition
sudo mkdir -p /mnt/boot
sudo mount /dev/nvme0n1p1 /mnt/boot

# Enable swap
sudo swapon /dev/nvme0n1p5
```

---

## Step 7: Generate Hardware Config

```bash
# Generate initial config
sudo nixos-generate-config --root /mnt

# View generated config
cat /mnt/etc/nixos/hardware-configuration.nix
```

---

## Step 8: Clone Configuration

```bash
# Network should already be configured (kexec preserves it)
# If not: sudo systemctl start wpa_supplicant

# Install git
nix-shell -p git

# Clone your config
sudo rm -rf /mnt/etc/nixos
git clone https://github.com/vince/darkwall-nixos /mnt/etc/nixos
```

---

## Step 9: Update hardware-configuration.nix

Edit `/mnt/etc/nixos/hosts/blep/hardware-configuration.nix`:

```bash
sudo nano /mnt/etc/nixos/hosts/blep/hardware-configuration.nix
```

Update with actual UUIDs from `blkid`:
```bash
blkid /dev/nvme0n1p1 /dev/nvme0n1p4 /dev/nvme0n1p5
```

---

## Step 10: Install NixOS

```bash
cd /mnt/etc/nixos
sudo nixos-install --flake .#blep --no-root-passwd
```

---

## Step 11: Reboot

```bash
sudo reboot
```

GRUB should show:
- NixOS (default)
- Fedora (via os-prober)

---

## Troubleshooting

### GRUB doesn't show Fedora
```bash
# After booting NixOS:
sudo os-prober
# Should detect Fedora

# Rebuild with os-prober
sudo nixos-rebuild switch --flake .#blep
```

### Fedora won't boot after partition changes
Boot Fedora recovery, fix `/etc/fstab` UUIDs if needed.

### kexec fails
Fall back to USB installer - download ISO and use Ventoy.

---

## Next Phase
Phase 4: Testing - Verify both OSes boot correctly.
