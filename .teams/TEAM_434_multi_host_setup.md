# TEAM_434: Multi-Host Setup

## Objective
Add support for multiple hosts managed from a single GitHub repo:
- **blep** - Desktop (dual-boot NixOS + Fedora)
- **workstation** - Headless GPU server (RTX 3090 + 3060) with ComfyUI, service accounts only
- **infra** - Infrastructure server (DNS, git, CA)

## Architecture Decisions

### Host Types
1. **Desktop** (`blep`): Full KDE Plasma, user profiles, home-manager
2. **Server** (`workstation`, `infra`): Headless, SSH-only, service accounts

### Service Accounts
Servers can have service-only users (no home-manager, no login shell):
```nix
users.users.comfyui = {
  isSystemUser = true;
  group = "comfyui";
  home = "/var/lib/comfyui";
  createHome = true;
};
users.groups.comfyui = {};
```

### Dual-Boot (blep)
- NixOS on first half of SSD
- Fedora on second half (manual install)
- GRUB configured to detect other OS via `os-prober`

## Files Created
- `hosts/blep/` - Desktop configuration
- `hosts/workstation/` - GPU server configuration  
- `hosts/infra/` - Infrastructure server configuration
- `modules/system/server.nix` - Shared headless server config

## Status
- [ ] Create host directories
- [ ] Update flake.nix
- [ ] Verify builds
