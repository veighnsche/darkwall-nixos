# darkwall-nixos

> A declarative, reproducible NixOS + Home Manager configuration using Nix Flakes.  
> Based on best practices from the [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/).

## Overview

This repository manages:

- **NixOS system configuration** — Full system: kernel, services, desktop, users
- **Home Manager configuration** — User-level: dotfiles, packages, shell, programs

Supports both NixOS (full system management) and standalone Home Manager (for Fedora/other distros).

### Key Features

- **KDE Plasma 6** desktop with Wayland
- **Multi-user setup** — `vince` (admin) + `guest` (restricted)
- **Modular architecture** — Reusable modules for hosts/users
- **VM-first development** — Test in VM before deploying to hardware
- **Reproducible** — `flake.lock` pins exact versions

## Repository Structure

```
darkwall-nixos/
├── flake.nix                 # Main entrypoint
├── flake.lock                # Version lock file
├── Justfile                  # Command runner (just <cmd>)
│
├── hosts/                    # Per-machine configurations
│   └── vm-test/              # VM for testing
│       ├── default.nix       # Machine-specific config
│       └── hardware-configuration.nix
│
├── modules/                  # Reusable NixOS modules
│   ├── system/               # Base system (nix, boot, networking, locale)
│   │   ├── default.nix
│   │   ├── nix.nix
│   │   ├── boot.nix
│   │   ├── networking.nix
│   │   └── locale.nix
│   ├── desktop/              # Desktop environment
│   │   ├── default.nix
│   │   ├── kde.nix
│   │   ├── audio.nix
│   │   └── fonts.nix
│   └── users/                # User definitions
│       ├── default.nix
│       ├── vince.nix
│       └── guest.nix
│
├── home/                     # Home Manager configs
│   ├── vince/
│   │   ├── default.nix       # NixOS-integrated config
│   │   ├── standalone.nix    # Fedora/non-NixOS config
│   │   ├── shell.nix
│   │   └── programs.nix
│   └── guest/
│       └── default.nix
│
├── packages/                 # Custom package derivations
│   └── windsurf.nix
│
├── dotfiles/                 # Managed configuration files
│   └── windsurf/
│       ├── mcp_config.json
│       ├── global_rules.md
│       └── workflows/
│
└── home-manager/             # [LEGACY] Old standalone config
```

## Quick Start

### Prerequisites

```bash
# Install Nix with flakes
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (~/.config/nix/nix.conf)
experimental-features = nix-command flakes
```

### Build & Run VM (Recommended First Step)

```bash
cd ~/Projects/darkwall-nixos

# Build the VM
just vm

# Run it (boots to KDE, autologin as vince)
./result/bin/run-vm-test-vm
```

### Deploy to NixOS

```bash
# On a NixOS machine, switch to this config
sudo nixos-rebuild switch --flake .#vm-test

# Or use just
just switch vm-test
```

### Standalone Home Manager (Fedora)

```bash
# For non-NixOS systems
just home

# Or directly
home-manager switch --flake .#vince@fedora
```

## Commands (Justfile)

| Command | Description |
|---------|-------------|
| **VM** | |
| `just vm` | Build QEMU VM image |
| `just vm-run` | Build and run VM |
| `just iso` | Build ISO for installation |
| **NixOS** | |
| `just switch [host]` | Rebuild and switch (default: vm-test) |
| `just build [host]` | Build without switching |
| `just test [host]` | Test without adding to bootloader |
| `just debug [host]` | Switch with verbose output |
| **Home Manager** | |
| `just home` | Apply standalone home-manager |
| `just home-build` | Build without applying |
| `just home-generations` | List generations |
| **Maintenance** | |
| `just update` | Update all flake inputs |
| `just update-input <name>` | Update specific input |
| `just gc` | Garbage collect old generations |
| `just gc-week` | Remove generations older than 7 days |
| `just history` | Show system generations |
| `just repl` | Open nix repl with flake |

## Architecture

### Module Organization

Following [NixOS & Flakes Book - Modularization](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration):

```
modules/
├── system/       → System-wide: boot, nix, networking, locale
├── desktop/      → GUI: KDE, audio, fonts
└── users/        → User accounts (links to home-manager)

home/
├── vince/        → Admin user config
└── guest/        → Guest user config (minimal)
```

### Separation of Concerns

| Layer | What | Where |
|-------|------|-------|
| **System** | Kernel, services, system packages | `modules/system/` |
| **Desktop** | Display manager, DE, audio, fonts | `modules/desktop/` |
| **Users** | Account definitions, groups | `modules/users/` |
| **Home** | User packages, dotfiles, shell | `home/<user>/` |

### Why This Structure?

1. **Hosts are thin** — Only machine-specific config (hostname, hardware)
2. **Modules are reusable** — Same desktop module for all machines
3. **Users are declarative** — Home Manager integrated, auto-deploys with system
4. **VM-first workflow** — Test everything before touching real hardware

### Input Follows Pattern

```nix
home-manager = {
  url = "github:nix-community/home-manager";
  inputs.nixpkgs.follows = "nixpkgs";  # Single nixpkgs instance
};
```

## Adding a New Host

1. Create `hosts/<hostname>/default.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     imports = [ ./hardware-configuration.nix ];
     networking.hostName = "<hostname>";
     # Machine-specific overrides...
   }
   ```

2. Generate hardware config on the target machine:
   ```bash
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. Add to `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
     inherit system specialArgs;
     modules = sharedModules ++ [ ./hosts/<hostname> ];
   };
   ```

## Adding a New User

1. Create system user in `modules/users/<username>.nix`:
   ```nix
   { config, lib, pkgs, ... }:
   {
     users.users.<username> = {
       isNormalUser = true;
       extraGroups = [ "wheel" "networkmanager" ];
       initialPassword = "changeme";
     };
     home-manager.users.<username> = import ../../home/<username>;
   }
   ```

2. Create home config in `home/<username>/default.nix`

3. Import in `modules/users/default.nix`

## Troubleshooting

### VM Won't Boot
```bash
# Check GRUB is targeting correct disk in hosts/vm-test/default.nix
boot.loader.grub.device = "/dev/vda";  # or /dev/sda
```

### "sha256 mismatch" Error
```bash
nix flake update
```

### Check Flake Syntax
```bash
nix flake check
```

### Debug Build Failures
```bash
just debug vm-test
# or
nixos-rebuild build --flake .#vm-test --show-trace
```

## References

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) — Primary guide
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Reference Manual](https://nixos.org/manual/nix/stable/)
- [nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)

## License

Personal configuration — feel free to use as reference.
