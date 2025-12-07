# Phase 2: Design — Agenix Secrets Management

## Proposed Solution

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Git Repository                          │
├─────────────────────────────────────────────────────────────┤
│  secrets/                                                   │
│  ├── secrets.nix        # Maps secrets → authorized keys    │
│  ├── ssh-key.age        # Encrypted SSH private key         │
│  └── ssh-key-pub.age    # Encrypted SSH public key          │
│                                                             │
│  flake.nix              # agenix input added                │
│  modules/secrets/       # agenix NixOS module               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (at activation time)
┌─────────────────────────────────────────────────────────────┐
│                     NixOS System                            │
├─────────────────────────────────────────────────────────────┤
│  /etc/ssh/ssh_host_ed25519_key   ← decryption key           │
│                                                             │
│  /run/agenix/                    ← decrypted secrets (tmpfs)│
│  ├── ssh-key                                                │
│  └── ssh-key-pub                                            │
│                                                             │
│  /home/vince/.ssh/                                          │
│  ├── id_ed25519  → /run/agenix/ssh-key (symlink or copy)    │
│  └── id_ed25519.pub → /run/agenix/ssh-key-pub               │
└─────────────────────────────────────────────────────────────┘
```

### Workflow

1. **One-time setup (on existing machine with the key):**
   ```bash
   # Get host public keys for all machines that need the secret
   ssh-keyscan -t ed25519 localhost | awk '{print $2 " " $3}'
   
   # Or use the host key directly
   cat /etc/ssh/ssh_host_ed25519_key.pub
   
   # Encrypt the secret
   cd ~/Projects/darkwall-nixos
   agenix -e secrets/ssh-key.age
   ```

2. **On fresh NixOS install:**
   - System boots
   - agenix reads `/etc/ssh/ssh_host_ed25519_key`
   - Decrypts `secrets/ssh-key.age` → `/run/agenix/ssh-key`
   - Home-manager symlinks `~/.ssh/id_ed25519` → `/run/agenix/ssh-key`
   - Git push works immediately

---

## File Structure

```
darkwall-nixos/
├── flake.nix                    # Add agenix input
├── secrets/
│   ├── secrets.nix              # Key → secret mapping
│   ├── ssh-key.age              # Encrypted private key
│   └── ssh-key-pub.age          # Encrypted public key
└── modules/
    └── secrets/
        └── default.nix          # agenix configuration
```

---

## API Design

### `secrets/secrets.nix`

```nix
# Maps secrets to the public keys that can decrypt them
let
  # Host SSH public keys (from /etc/ssh/ssh_host_ed25519_key.pub)
  blep = "ssh-ed25519 AAAA... root@blep";
  vm-test = "ssh-ed25519 AAAA... root@vm-test";
  
  # User keys (optional, for encrypting from user machines)
  vince = "ssh-ed25519 AAAA... vince@fedora";
  
  # All systems that should have access
  allSystems = [ blep vm-test ];
  allUsers = [ vince ];
  all = allSystems ++ allUsers;
in {
  "ssh-key.age".publicKeys = all;
  "ssh-key-pub.age".publicKeys = all;
}
```

### `modules/secrets/default.nix`

```nix
{ config, lib, pkgs, ... }:

{
  # Import agenix module (done in flake.nix)
  
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
}
```

### Home-manager integration

```nix
# In home/vince/default.nix or a dedicated ssh.nix
{ config, ... }:

{
  home.file.".ssh/id_ed25519" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-key";
  };
  home.file.".ssh/id_ed25519.pub" = {
    source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-key-pub";
  };
}
```

---

## Behavioral Decisions

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| Host key not found | agenix fails activation with clear error |
| Secret not encrypted to this host | agenix fails activation with clear error |
| `/run/agenix` not mounted | Secrets unavailable (system misconfigured) |
| User tries to edit decrypted secret | Changes lost on reboot (tmpfs) |

### Error Handling

- **Missing host key:** agenix prints which key it tried and fails
- **Decryption failure:** agenix prints the secret name and fails
- **Permission denied:** Check file modes in `age.secrets`

### Defaults

- Secrets decrypted to `/run/agenix/<name>` (agenix default)
- Owner/group/mode must be explicitly set per secret
- Symlinks used for user-facing paths (not copies)

---

## Bootstrap Workflow for New Hosts

### Before installing a new host:

1. **Get the host's SSH public key** (after NixOS installer runs):
   ```bash
   # From the installer or live system
   cat /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. **Add to `secrets/secrets.nix`:**
   ```nix
   newhost = "ssh-ed25519 AAAA... root@newhost";
   allSystems = [ blep vm-test newhost ];
   ```

3. **Re-encrypt secrets:**
   ```bash
   cd ~/Projects/darkwall-nixos
   agenix -r  # Re-encrypt all secrets with new recipients
   git add secrets/
   git commit -m "Add newhost to secrets recipients"
   git push
   ```

4. **Install NixOS on new host** — secrets will decrypt automatically

### For VM testing:

The VM generates a new host key each boot (ephemeral). Options:
1. **Persist VM disk** — host key survives reboots
2. **Add VM host key to secrets.nix** — requires knowing key in advance
3. **Skip secrets in VM** — use conditional `lib.mkIf (!config.virtualisation.vmVariant)`

**Recommendation:** Option 3 for VMs (secrets not critical for testing)

---

## Open Questions

### Q1: Same SSH key across all machines or per-machine?

**Options:**
- **A) Same key:** One `id_ed25519` used everywhere
  - Pro: Simple, one GitHub SSH key to manage
  - Con: If one machine is compromised, all are
  
- **B) Per-machine keys:** Each host has its own git SSH key
  - Pro: Better security isolation
  - Con: Must add each key to GitHub, more management

**Recommendation:** Option A (same key) for simplicity. Can migrate to B later.

### Q2: Where is your current SSH private key?

Need the path to encrypt it. Likely one of:
- `~/.ssh/id_ed25519` on Fedora
- A backup location

### Q3: Do you have the host SSH public keys for blep?

For the real NixOS machine, we need:
```bash
cat /etc/ssh/ssh_host_ed25519_key.pub
```

If not available yet, we can add it after first boot and re-encrypt.

---

## Design Alternatives Considered

### Alternative 1: sops-nix

- Similar to agenix but uses Mozilla SOPS
- Supports more backends (age, GPG, AWS KMS, etc.)
- More complex setup
- **Rejected:** agenix is simpler and sufficient for our needs

### Alternative 2: Manual key copy

- No encryption, just document the manual step
- **Rejected:** Defeats the purpose of declarative config

### Alternative 3: Generate new key per host

- Each host generates its own SSH key at first boot
- Add to GitHub manually
- **Rejected:** Loses key continuity, more GitHub management

---

## Next Phase

Once questions Q1-Q3 are answered, proceed to **Phase 3: Implementation** with:
- Step 1: Add agenix to flake.nix
- Step 2: Create secrets module
- Step 3: Encrypt SSH key
- Step 4: Integrate with home-manager
- Step 5: Test in VM
