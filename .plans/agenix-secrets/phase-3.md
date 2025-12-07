# Phase 3: Implementation — Agenix Secrets Management

> **Prerequisites:** Questions from Phase 2 must be answered before executing.

## Implementation Steps

### Step 1: Add agenix to flake.nix

**File:** `flake.nix`

```nix
inputs = {
  # ... existing inputs ...
  
  agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

Add to shared modules:
```nix
sharedModules = [
  agenix.nixosModules.default
  # ... rest ...
];
```

**UoW:** ~10 lines changed

---

### Step 2: Create secrets directory structure

**Files to create:**

```
secrets/
├── secrets.nix    # Key mapping
├── .gitignore     # Ignore decrypted files if any
└── README.md      # Usage instructions
```

**UoW:** 3 new files, ~50 lines total

---

### Step 3: Create secrets module

**File:** `modules/secrets/default.nix`

```nix
{ config, lib, pkgs, ... }:

{
  age.secrets = {
    ssh-key = {
      file = ../../secrets/ssh-key.age;
      owner = "vince";
      group = "users";
      mode = "600";
    };
    ssh-key-pub = {
      file = ../../secrets/ssh-key-pub.age;
      owner = "vince";
      group = "users";
      mode = "644";
    };
  };
  
  # Ensure agenix identity is the host SSH key
  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
```

**UoW:** 1 new file, ~25 lines

---

### Step 4: Encrypt SSH key

**Commands (run on Fedora with existing key):**

```bash
# Install agenix CLI
nix-shell -p agenix

# Create secrets.nix with public keys first
# Then encrypt
cd ~/Projects/darkwall-nixos
agenix -e secrets/ssh-key.age      # Opens editor, paste private key
agenix -e secrets/ssh-key-pub.age  # Opens editor, paste public key
```

**UoW:** 2 encrypted files created

---

### Step 5: Integrate with home-manager

**File:** `home/vince/ssh.nix` (new)

```nix
{ config, lib, ... }:

{
  # Symlink decrypted secrets to ~/.ssh/
  home.file.".ssh/id_ed25519" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-key";
  };
  home.file.".ssh/id_ed25519.pub" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-key-pub";
  };
  
  # Ensure .ssh directory has correct permissions
  home.file.".ssh/.keep" = {
    text = "";
    onChange = ''
      chmod 700 ~/.ssh
    '';
  };
}
```

**Import in:** `home/vince/default.nix`

**UoW:** 1 new file, ~20 lines; 1 line added to imports

---

### Step 6: Add secrets module to system

**File:** `modules/system/default.nix` or create `modules/secrets/default.nix`

Import the secrets module in the shared modules.

**UoW:** ~5 lines

---

### Step 7: Conditional for VM (optional)

If secrets should be skipped in VM:

```nix
{ config, lib, ... }:

{
  age.secrets = lib.mkIf (!config.virtualisation ? vmVariant) {
    # ... secrets ...
  };
}
```

Or handle missing secrets gracefully in home-manager.

**UoW:** ~10 lines

---

## Execution Order

1. Step 1: Add agenix input to flake
2. Step 2: Create secrets directory
3. Step 3: Create secrets module
4. Step 6: Import secrets module
5. Step 4: Encrypt SSH key (requires user's key)
6. Step 5: Integrate with home-manager
7. Step 7: VM conditional (if needed)
8. Test build
9. Test in VM (may fail without secrets — expected)
10. Test on real hardware (if available)

---

## Verification

### Build test
```bash
nix build .#nixosConfigurations.vm-test.config.system.build.vm
nix build .#nixosConfigurations.blep.config.system.build.toplevel
```

### Functional test (on real NixOS)
```bash
# After switch
ls -la ~/.ssh/
cat ~/.ssh/id_ed25519.pub
ssh -T git@github.com  # Should authenticate
```

---

## Rollback Plan

If something breaks:
1. Remove agenix from flake inputs
2. Remove secrets module import
3. Rebuild

Secrets are additive — removing them doesn't break existing functionality.
