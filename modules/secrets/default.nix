# TEAM_446: Agenix secrets module
# Decrypts secrets at system activation time
#
# Secrets are stored encrypted in /secrets/*.age
# Decrypted to /run/agenix/ (tmpfs, never persisted)
{ config, lib, pkgs, ... }:

{
  # TEAM_446: Define secrets to decrypt
  age.secrets = {
    # SSH private key for git operations
    ssh-key = {
      file = ../../secrets/ssh-key.age;
      owner = "vince";
      group = "users";
      mode = "600";  # Only owner can read
    };
    
    # SSH public key (convenience, could be plaintext)
    ssh-key-pub = {
      file = ../../secrets/ssh-key-pub.age;
      owner = "vince";
      group = "users";
      mode = "644";  # World-readable
    };
  };

  # TEAM_446: Use host SSH key for decryption
  # This key is generated automatically at NixOS install
  # After install, add the public key to secrets/secrets.nix and re-encrypt
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
  ];
}
