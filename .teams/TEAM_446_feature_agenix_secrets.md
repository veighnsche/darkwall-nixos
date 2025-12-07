# TEAM_446: Feature - Agenix Secrets Management

## Purpose

Add agenix to manage secrets (SSH keys, API tokens) declaratively and securely.

## Status

- [x] Team registered
- [x] Feature plan created
- [x] Phase 1: Discovery — `.plans/agenix-secrets/phase-1.md`
- [x] Phase 2: Design — `.plans/agenix-secrets/phase-2.md`
- [x] Phase 3: Implementation — **COMPLETED**
- [x] Phase 4: Integration & Testing — builds pass
- [x] Phase 5: Polish & Docs — `secrets/README.md` created

## Plan Location

`.plans/agenix-secrets/`

## Implementation Summary

### Files Created/Modified

| File | Purpose |
|------|---------|
| `flake.nix` | Added agenix input |
| `secrets/secrets.nix` | Key → secret mapping |
| `secrets/ssh-key.age` | Encrypted SSH private key |
| `secrets/ssh-key-pub.age` | Encrypted SSH public key |
| `secrets/README.md` | Usage documentation |
| `modules/secrets/default.nix` | Agenix NixOS module |
| `home/vince/ssh.nix` | Symlinks secrets to `~/.ssh/` |

### Current State

- Secrets encrypted to vince's personal key
- No host keys added yet (add after NixOS install)
- Both `vm-test` and `blep` builds pass

### Next Steps (After NixOS Install)

1. Get host key: `cat /etc/ssh/ssh_host_ed25519_key.pub`
2. Add to `secrets/secrets.nix` in `allSystems`
3. Re-encrypt: `nix-shell -p agenix && agenix -r`
4. Rebuild — SSH key will be available immediately

## Handoff

- [x] Project builds cleanly
- [x] All tests pass (build verification)
- [x] Documentation created (`secrets/README.md`)
- [x] Team file updated
