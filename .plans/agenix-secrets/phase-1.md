# Phase 1: Discovery — Agenix Secrets Management

## Feature Summary

**Problem:** Secrets (SSH keys for git, API tokens, passwords) cannot be stored in the git repo in plaintext. Currently, after a fresh NixOS install, users must manually copy SSH keys to enable `git push` to the config repo.

**Solution:** Use [agenix](https://github.com/ryantm/agenix) to encrypt secrets with age keys. Secrets are stored encrypted in the repo and decrypted at system activation time.

**Who benefits:** Any admin user (vince) who needs secrets available on fresh installs without manual intervention.

## Success Criteria

1. SSH private key for git is encrypted in the repo
2. On system activation, the key is decrypted to `~/.ssh/id_ed25519`
3. `git push` works immediately after first boot (no manual key copy)
4. Secrets are never stored in plaintext in the repo or Nix store
5. Adding new secrets is documented and straightforward

## Current State Analysis

### How it works today (without agenix)

1. User installs NixOS from the flake
2. Bootstrap script copies flake repo to `~/Projects/darkwall-nixos`
3. Git is initialized with remote `git@github.com:veighnsche/darkwall-nixos.git`
4. **PROBLEM:** No SSH key exists → `git push` fails
5. User must manually copy `~/.ssh/id_ed25519` from another machine

### Current workarounds

- Manual key copy via USB or `scp` from another machine
- Generate new key and add to GitHub (loses commit signing continuity)

## Codebase Reconnaissance

### Files likely touched

| File | Purpose |
|------|---------|
| `flake.nix` | Add agenix input |
| `modules/secrets/default.nix` | New module for agenix config |
| `modules/users/vince.nix` | Reference decrypted secrets |
| `secrets/secrets.nix` | Define which keys can decrypt which secrets |
| `secrets/*.age` | Encrypted secret files |

### Dependencies

- `agenix` flake input
- `age` CLI tool (for encrypting secrets)
- Host SSH key or age key for decryption

### Tests/Snapshots impacted

- None directly (secrets are runtime, not build-time)
- VM testing will need the age key available

## Constraints

1. **Security:** Private keys must never appear in:
   - Git history (plaintext)
   - Nix store (readable by all users)
   - Build logs

2. **Bootstrapping:** Need a way to decrypt on first boot
   - Option A: Use host SSH key (generated at install time)
   - Option B: Use a master age key (must be provisioned somehow)

3. **Multi-host:** Different hosts may need different secrets
   - Each host has its own SSH host key
   - Secrets can be encrypted to multiple recipients

---

## Phase 1 Steps

### Step 1: Understand agenix architecture ✓

Agenix works as follows:
1. Secrets are encrypted with `age` to one or more public keys
2. Public keys are listed in `secrets/secrets.nix`
3. At activation, agenix decrypts secrets using the host's SSH key
4. Decrypted secrets are placed in `/run/agenix/` (tmpfs, not persisted)
5. Symlinks or copies can place secrets in user directories

### Step 2: Identify secrets to manage

| Secret | Purpose | Owner | Permissions |
|--------|---------|-------|-------------|
| `id_ed25519` | Git SSH key | vince | 600 |
| `id_ed25519.pub` | Git SSH public key | vince | 644 |

Future secrets (not in scope for this phase):
- API tokens
- Database passwords
- Service account keys

### Step 3: Determine decryption key strategy

**Decision needed:** How does the host decrypt secrets on first boot?

**Options:**
1. **Host SSH key** — NixOS generates `/etc/ssh/ssh_host_ed25519_key` at install
   - Pro: Automatic, no manual step
   - Con: Must add host pubkey to `secrets.nix` before install
   
2. **Shared age key** — A master key stored... somewhere
   - Pro: Works across all hosts
   - Con: Where do you store the master key? (chicken-egg problem)

3. **Hybrid** — Use host SSH key, re-encrypt secrets after install
   - Pro: Works for fresh installs
   - Con: Requires re-encryption step

**Recommendation:** Option 1 (host SSH key) with a bootstrap workflow.

---

## Questions for User

1. **Do you have an existing SSH key you want to use across all machines?**
   - If yes: We'll encrypt to that key's public counterpart
   - If no: We'll use per-host SSH keys

2. **Where is your current SSH private key stored?**
   - Need to know so we can encrypt secrets to it

3. **Do you want the same git SSH key on all machines, or per-machine keys?**
   - Same key: Simpler, one GitHub deploy key
   - Per-machine: More secure, requires adding each key to GitHub

---

## Next Phase

Once questions are answered, proceed to **Phase 2: Design** to define:
- Exact file structure for secrets
- Agenix module configuration
- Bootstrap workflow for new hosts
