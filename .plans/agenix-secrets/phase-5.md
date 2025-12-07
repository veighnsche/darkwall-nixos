# Phase 5: Polish & Documentation — Agenix Secrets Management

## Documentation Tasks

### Task 1: secrets/README.md

Create a README explaining:
- What agenix is and how it works
- How to add a new secret
- How to add a new host
- How to re-encrypt after adding hosts
- Troubleshooting common issues

### Task 2: Update main README

Add a "Secrets Management" section to the project README:
- Brief overview
- Link to secrets/README.md
- Quick commands for common operations

### Task 3: Inline documentation

Ensure all secrets-related Nix files have clear comments:
- `secrets/secrets.nix` — explain the key mapping
- `modules/secrets/default.nix` — explain each secret
- `home/vince/ssh.nix` — explain the symlink strategy

## Cleanup Tasks

### Task 1: Remove temporary code

- Remove any debug logging added during development
- Remove any commented-out alternatives

### Task 2: Verify no plaintext secrets

```bash
# Final check: no private keys in repo
git log -p | grep -i "PRIVATE KEY" | head
# Should return nothing

# Check current files
grep -r "PRIVATE KEY" . --include="*.nix" --include="*.md"
# Should only find documentation references
```

### Task 3: Update .gitignore

Ensure decrypted secrets are never committed:
```
# In secrets/.gitignore
*.decrypted
*.plaintext
```

## Handoff Checklist

- [ ] All secrets encrypted and committed
- [ ] secrets/README.md created
- [ ] Main README updated
- [ ] All Nix files have clear comments
- [ ] No plaintext secrets in repo
- [ ] Build succeeds for all hosts
- [ ] Tested on real hardware (if available)
- [ ] Team file updated with completion status

## Future Enhancements (Out of Scope)

Document for future teams:

1. **Additional secrets to add:**
   - API tokens for services
   - Database passwords
   - Wireless network passwords (wpa_supplicant)

2. **Per-host secrets:**
   - Different secrets for different machines
   - Use `age.secrets.<name>.file` with host-specific paths

3. **Secret rotation:**
   - Process for rotating compromised keys
   - Re-encryption workflow

4. **Backup strategy:**
   - How to backup the master key
   - Recovery process if all hosts are lost
