# TEAM_426: NixOS/Home Manager command runner
# Usage: just <command>

# Default host for NixOS
default_host := "vm-test"

# ════════════════════════════════════════════════════════════════════════════
# NixOS Commands (for actual NixOS systems)
# ════════════════════════════════════════════════════════════════════════════

# Rebuild and switch NixOS configuration
[linux]
switch host=default_host:
    sudo nixos-rebuild switch --flake .#{{host}}

# Rebuild with debug output
[linux]
debug host=default_host:
    sudo nixos-rebuild switch --flake .#{{host}} --show-trace --verbose

# Build without switching (dry run)
[linux]
build host=default_host:
    nixos-rebuild build --flake .#{{host}}

# Test configuration (activate without adding to bootloader)
[linux]
test host=default_host:
    sudo nixos-rebuild test --flake .#{{host}}

# ════════════════════════════════════════════════════════════════════════════
# VM Commands
# ════════════════════════════════════════════════════════════════════════════

# Build a QEMU VM image
vm:
    nix build .#nixosConfigurations.vm-test.config.system.build.vm
    @echo "Run with: ./result/bin/run-vm-test-vm"

# Build and run the VM
vm-run:
    nix build .#nixosConfigurations.vm-test.config.system.build.vm
    ./result/bin/run-vm-test-vm

# TEAM_442: Verify running VM via SSH
vm-verify:
    ./scripts/vm-verify.sh

# TEAM_442: Build, run VM in background, wait for SSH, then verify
vm-test:
    nix build .#nixosConfigurations.vm-test.config.system.build.vm
    @echo "Starting VM in background..."
    ./result/bin/run-vm-test-vm &
    @./scripts/wait-for-ssh.sh
    ./scripts/vm-verify.sh

# Build an ISO image for installation
iso:
    nix build .#nixosConfigurations.vm-test.config.system.build.isoImage
    @echo "ISO available at: ./result/iso/"

# ════════════════════════════════════════════════════════════════════════════
# Home Manager Commands (for non-NixOS systems like Fedora)
# ════════════════════════════════════════════════════════════════════════════

# Apply home-manager configuration (standalone)
home:
    home-manager switch --flake .#vince@fedora -b backup

# Apply home-manager with debug output
home-debug:
    home-manager switch --flake .#vince@fedora -b backup --show-trace

# Build home-manager without switching
home-build:
    home-manager build --flake .#vince@fedora

# List home-manager generations
home-generations:
    home-manager generations

# ════════════════════════════════════════════════════════════════════════════
# Flake Management
# ════════════════════════════════════════════════════════════════════════════

# Update all flake inputs
update:
    nix flake update

# Update a specific input
update-input input:
    nix flake update {{input}}

# Show flake outputs
show:
    nix flake show

# Show flake metadata
info:
    nix flake metadata

# Check flake for errors
check:
    nix flake check

# ════════════════════════════════════════════════════════════════════════════
# Maintenance
# ════════════════════════════════════════════════════════════════════════════

# Garbage collect old generations (NixOS)
[linux]
gc:
    sudo nix-collect-garbage --delete-old

# Garbage collect generations older than 7 days
[linux]
gc-week:
    sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 7d
    sudo nix-collect-garbage --delete-old

# Optimize nix store
[linux]
optimize:
    nix store optimise

# Show system generations (NixOS)
[linux]
history:
    nix profile history --profile /nix/var/nix/profiles/system

# Open nix repl with flake
repl:
    nix repl --expr 'builtins.getFlake (toString ./.)'

# ════════════════════════════════════════════════════════════════════════════
# Development
# ════════════════════════════════════════════════════════════════════════════

# Format all nix files
fmt:
    find . -name "*.nix" -exec nixfmt {} \;

# List all available hosts
hosts:
    @echo "Available NixOS hosts:"
    @nix flake show --json 2>/dev/null | jq -r '.nixosConfigurations | keys[]'
