# Workstation Deployment Checklist

This document contains everything needed to deploy the workstation (headless GPU server with ComfyUI).

## Hardware
- **CPU**: Intel i7-6850K
- **RAM**: 80GB
- **GPUs**: RTX 3090 + RTX 3060
- **Storage**: 4x 250GB SSDs in LVM (vg_models)

---

## Pre-Deployment Steps (from any Linux live USB)

### 1. Generate SSH Key Pair (on blep)

```bash
# On blep (your desktop)
ssh-keygen -t ed25519 -C "admin@blep" -f ~/.ssh/workstation_admin

# Copy the public key
cat ~/.ssh/workstation_admin.pub
# Output: ssh-ed25519 AAAA... admin@blep
```

### 2. Add SSH Key to Configuration

Edit `hosts/workstation/default.nix` line 56-59:

```nix
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... admin@blep"  # Replace with actual key
];
```

### 3. Boot NixOS Installer on Workstation

1. Download NixOS minimal ISO
2. Write to USB: `dd if=nixos.iso of=/dev/sdX bs=4M status=progress`
3. Boot workstation from USB

### 4. Partition Disks

```bash
# Identify disks
lsblk

# Create partitions on boot drive (e.g., /dev/sda)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary ext4 512MiB -16GiB
parted /dev/sda -- mkpart primary linux-swap -16GiB 100%

# Format
mkfs.fat -F 32 -n BOOT /dev/sda1
mkfs.ext4 -L nixos /dev/sda2
mkswap -L swap /dev/sda3
```

### 5. Setup LVM for Models

```bash
# Create LVM on 4x 250GB SSDs (adjust device names)
pvcreate /dev/sdb /dev/sdc /dev/sdd /dev/sde
vgcreate vg_models /dev/sdb /dev/sdc /dev/sdd /dev/sde
lvcreate -l 100%FREE -n lv_models vg_models

# Format
mkfs.ext4 /dev/vg_models/lv_models
```

### 6. Mount and Generate Config

```bash
# Mount
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
swapon /dev/disk/by-label/swap

# Generate hardware config
nixos-generate-config --root /mnt

# Copy the generated hardware-configuration.nix
cat /mnt/etc/nixos/hardware-configuration.nix
```

### 7. Update hardware-configuration.nix

Replace `hosts/workstation/hardware-configuration.nix` with the generated one.

Keep these additions:
```nix
# Intel Broadwell-E CPU
hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
```

### 8. Install NixOS

```bash
# Clone the repo
nix-shell -p git
git clone https://github.com/YOUR_USER/darkwall-nixos /mnt/etc/nixos/darkwall

# Install
nixos-install --flake /mnt/etc/nixos/darkwall#workstation

# Set root password when prompted
# Reboot
reboot
```

---

## Post-Deployment Steps

### 1. SSH into Workstation

```bash
# From blep
ssh -i ~/.ssh/workstation_admin admin@workstation.local
# or use IP address
ssh -i ~/.ssh/workstation_admin admin@192.168.x.x
```

### 2. Verify Services

```bash
# Check ComfyUI container
sudo podman ps
sudo systemctl status podman-comfyui

# Check GPU access
nvidia-smi

# Check container health
sudo podman healthcheck run comfyui
```

### 3. Access ComfyUI Web UI

From blep browser: `http://workstation.local:8188` or `http://192.168.x.x:8188`

### 4. Copy Models from Old System

If you have models on another drive:

```bash
# Mount old drive
sudo mount /dev/sdX1 /mnt/old

# Copy models
sudo rsync -avP /mnt/old/models/ /mnt/models/
sudo chown -R comfyui:comfyui /mnt/models/
```

---

## Management Commands

```bash
# View ComfyUI logs
journalctl -u podman-comfyui -f

# Restart ComfyUI
sudo systemctl restart podman-comfyui

# Shell into container
sudo podman exec -it comfyui bash

# Update container image
sudo podman pull ghcr.io/ai-dock/comfyui:pytorch-2.4.1-py3.11-cuda-12.4.1-runtime-22.04
sudo systemctl restart podman-comfyui

# Check disk usage
df -h /mnt/models
ncdu /mnt/models
```

---

## Troubleshooting

### Container won't start
```bash
# Check logs
journalctl -u podman-comfyui -n 100

# Check if models volume is mounted
mount | grep models

# Manual container start for debugging
sudo podman run --rm -it \
  --device=nvidia.com/gpu=all \
  -v /var/lib/comfyui:/workspace/ComfyUI \
  ghcr.io/ai-dock/comfyui:pytorch-2.4.1-py3.11-cuda-12.4.1-runtime-22.04 \
  bash
```

### GPU not detected
```bash
# Check NVIDIA driver
nvidia-smi

# Check container toolkit
sudo podman run --rm --device=nvidia.com/gpu=all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

### Permission denied on models
```bash
# Fix ownership
sudo chown -R comfyui:comfyui /mnt/models /var/lib/comfyui
```

---

## Configuration Files

| File | Purpose |
|------|---------|
| `hosts/workstation/default.nix` | Main workstation config |
| `hosts/workstation/storage.nix` | LVM mount for models |
| `hosts/workstation/hardware-configuration.nix` | Hardware-specific (generate on device) |
| `modules/system/server.nix` | Shared headless server config |
