# Secrets Management (agenix)

This directory contains encrypted secrets managed by [agenix](https://github.com/ryantm/agenix).

## How it works

1. Secrets are encrypted with `age` to specific public keys
2. At system activation, agenix decrypts them using the host's SSH key
3. Decrypted secrets appear in `/run/agenix/` (tmpfs, never persisted to disk)
4. Home-manager symlinks them to user directories (e.g., `~/.ssh/`)

## Files

| File | Description |
|------|-------------|
| `secrets.nix` | Maps secrets to authorized public keys |
| `ssh-key.age` | Encrypted SSH private key |
| `ssh-key-pub.age` | Encrypted SSH public key |

## Adding a new host

After installing NixOS on a new machine:

```bash
# 1. Get the host's SSH public key
ssh newhost "cat /etc/ssh/ssh_host_ed25519_key.pub"

# 2. Add it to secrets.nix
#    newhost = "ssh-ed25519 AAAA... root@newhost";
#    allSystems = [ ... newhost ];

# 3. Re-encrypt all secrets
nix-shell -p agenix
cd ~/Projects/darkwall-nixos
agenix -r

# 4. Commit and push
git add secrets/
git commit -m "Add newhost to secrets recipients"
git push

# 5. Rebuild on the new host
sudo nixos-rebuild switch --flake .#newhost
```

## Adding a new secret

```bash
# 1. Enter nix shell with agenix
nix-shell -p agenix

# 2. Add the secret definition to secrets.nix
#    "new-secret.age".publicKeys = all;

# 3. Encrypt the secret (opens $EDITOR)
agenix -e secrets/new-secret.age

# 4. Add to modules/secrets/default.nix
#    age.secrets.new-secret = {
#      file = ../../secrets/new-secret.age;
#      owner = "vince";
#      mode = "600";
#    };

# 5. Commit and rebuild
git add secrets/
git commit -m "Add new-secret"
```

## Decrypting locally (for debugging)

```bash
# Decrypt with your SSH key
age -d -i ~/.ssh/id_ed25519 secrets/ssh-key.age
```

## Troubleshooting

### "no identity found"

The host's SSH key is not in `secrets.nix`. Add it and re-encrypt:
```bash
cat /etc/ssh/ssh_host_ed25519_key.pub  # Get the key
# Add to secrets.nix
agenix -r  # Re-encrypt
```

### "permission denied" on decrypted secret

Check the `mode` in `modules/secrets/default.nix`. SSH private keys need `600`.

### Secrets not appearing in `/run/agenix/`

Check `journalctl -u agenix` for errors. Usually means the host key isn't authorized.
