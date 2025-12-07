# TEAM_446: Feature - Agenix Secrets Management

## Purpose

Add agenix to manage secrets (SSH keys, API tokens) declaratively and securely.

## Status

- [x] Team registered
- [x] Feature plan created
- [x] Phase 1: Discovery — `.plans/agenix-secrets/phase-1.md`
- [x] Phase 2: Design — `.plans/agenix-secrets/phase-2.md`
- [x] Phase 3: Implementation — `.plans/agenix-secrets/phase-3.md`
- [x] Phase 4: Integration & Testing — `.plans/agenix-secrets/phase-4.md`
- [x] Phase 5: Polish & Docs — `.plans/agenix-secrets/phase-5.md`

## Plan Location

`.plans/agenix-secrets/`

## Questions Requiring User Input

Before implementation can proceed, answer these questions in Phase 2:

1. **Same SSH key across all machines or per-machine?**
   - Recommendation: Same key for simplicity

2. **Where is your current SSH private key?**
   - Need path to encrypt it (likely `~/.ssh/id_ed25519`)

3. **Do you have the host SSH public key for blep?**
   - Run: `cat /etc/ssh/ssh_host_ed25519_key.pub` on blep
   - If not available yet, can add after first boot

## Quick Start (After Questions Answered)

```bash
# 1. Add agenix to flake (Phase 3, Step 1)
# 2. Create secrets directory structure
# 3. Get host public keys
# 4. Encrypt secrets:
nix-shell -p agenix
agenix -e secrets/ssh-key.age
# 5. Rebuild and test
```
