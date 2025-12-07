# TEAM_446: Agenix secrets configuration
# Maps secrets to the public keys that can decrypt them
#
# To add a new host:
#   1. Get host SSH public key: cat /etc/ssh/ssh_host_ed25519_key.pub
#   2. Add it below
#   3. Re-encrypt all secrets: agenix -r
#   4. Commit and push
let
  # ════════════════════════════════════════════════════════════════
  # User Keys (for encrypting from user machines)
  # ════════════════════════════════════════════════════════════════
  # Vince's personal key - tied to identity, same across all machines
  vince = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6lMXGI0/5HqCeMcO6V5Zt5v5w2NT1/yLBapxOvkIsx vincepaul.liem@gmail.com";

  # ════════════════════════════════════════════════════════════════
  # Host SSH Keys (for decryption at activation time)
  # ════════════════════════════════════════════════════════════════
  # Add host keys here after NixOS install:
  #   cat /etc/ssh/ssh_host_ed25519_key.pub
  #
  # blep = "ssh-ed25519 AAAA... root@blep";
  # vm-test = "ssh-ed25519 AAAA... root@vm-test";

  # ════════════════════════════════════════════════════════════════
  # Key Groups
  # ════════════════════════════════════════════════════════════════
  # For now, only vince's key can decrypt (bootstrap phase)
  # After hosts are set up, add them to allSystems
  allUsers = [ vince ];
  allSystems = [ ];  # Add host keys here after first boot
  all = allUsers ++ allSystems;

in {
  # SSH private key for git operations
  "ssh-key.age".publicKeys = all;
  
  # SSH public key (for convenience, could also be plaintext)
  "ssh-key-pub.age".publicKeys = all;
}
