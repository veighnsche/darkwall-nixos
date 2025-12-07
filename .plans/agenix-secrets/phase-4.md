# Phase 4: Integration & Testing — Agenix Secrets Management

## Test Matrix

| Test | Environment | Expected Result |
|------|-------------|-----------------|
| Build succeeds | Host (Fedora) | `nix build` completes |
| VM boots | QEMU | System starts, SDDM appears |
| Secrets skipped in VM | QEMU | No agenix errors (conditional) |
| Secrets decrypt on real NixOS | blep | `/run/agenix/ssh-key` exists |
| SSH key symlinked | blep | `~/.ssh/id_ed25519` → `/run/agenix/ssh-key` |
| Git push works | blep | `git push` authenticates |

## Test Procedures

### Test 1: Build verification

```bash
cd ~/Projects/darkwall-nixos

# VM build
nix build .#nixosConfigurations.vm-test.config.system.build.vm

# Real hardware build
nix build .#nixosConfigurations.blep.config.system.build.toplevel
```

**Pass criteria:** Both complete without errors

### Test 2: VM boot test

```bash
just vm-run
```

**Pass criteria:** 
- VM boots to SDDM
- No agenix-related errors in journal
- If secrets are conditional, they should be skipped cleanly

### Test 3: Secret decryption (real hardware)

```bash
# On blep after nixos-rebuild switch
ls -la /run/agenix/
# Should show: ssh-key, ssh-key-pub

cat /run/agenix/ssh-key-pub
# Should show the public key
```

**Pass criteria:** Files exist with correct permissions

### Test 4: Home-manager symlinks

```bash
# On blep
ls -la ~/.ssh/
# Should show:
# id_ed25519 -> /run/agenix/ssh-key
# id_ed25519.pub -> /run/agenix/ssh-key-pub

stat ~/.ssh/id_ed25519
# Should show mode 0600
```

**Pass criteria:** Symlinks exist and point to correct targets

### Test 5: Git authentication

```bash
# On blep
ssh -T git@github.com
# Should say: Hi veighnsche! You've successfully authenticated...

cd ~/Projects/darkwall-nixos
git fetch origin
# Should succeed without password prompt
```

**Pass criteria:** GitHub authenticates with the SSH key

## Regression Checks

### Existing functionality preserved

- [ ] VM still boots with shared folder mount
- [ ] Niri config still symlinked correctly
- [ ] Zsh configuration still works
- [ ] All existing packages still available

### Security checks

- [ ] Private key NOT in `/nix/store` (grep for key content)
- [ ] Private key NOT in git history plaintext
- [ ] `/run/agenix/ssh-key` has mode 600
- [ ] Only vince can read the private key

```bash
# Verify key not in store
grep -r "PRIVATE KEY" /nix/store/ 2>/dev/null | head
# Should return nothing related to our key

# Verify permissions
stat /run/agenix/ssh-key
# Should show: Access: (0600/-rw-------)  Uid: (1000/vince)
```

## Error Scenarios

### Scenario: Host key not in secrets.nix

**Symptom:** Activation fails with "no identity found"

**Fix:** 
1. Get host public key: `cat /etc/ssh/ssh_host_ed25519_key.pub`
2. Add to `secrets/secrets.nix`
3. Re-encrypt: `agenix -r`
4. Commit and push
5. Rebuild

### Scenario: Secret file corrupted

**Symptom:** Decryption fails with age error

**Fix:**
1. Re-encrypt from source: `agenix -e secrets/ssh-key.age`
2. Commit and push
3. Rebuild

### Scenario: Wrong permissions on decrypted file

**Symptom:** SSH refuses to use key ("permissions too open")

**Fix:** Check `mode` in `age.secrets` configuration
