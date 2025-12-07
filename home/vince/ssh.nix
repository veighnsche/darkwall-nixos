# TEAM_446: SSH configuration with agenix secrets
# Symlinks decrypted secrets from /run/agenix/ to ~/.ssh/
{ config, lib, pkgs, ... }:

{
  # TEAM_446: Symlink decrypted SSH keys to ~/.ssh/
  # The actual keys are decrypted by agenix at system activation
  # and placed in /run/agenix/ (tmpfs)
  home.file = {
    ".ssh/id_ed25519" = {
      source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-key";
    };
    ".ssh/id_ed25519.pub" = {
      source = config.lib.file.mkOutOfStoreSymlink "/run/agenix/ssh-key-pub";
    };
  };

  # TEAM_446: Ensure SSH directory exists with correct permissions
  home.activation.ensureSshDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
  '';

  # TEAM_446: SSH client configuration
  programs.ssh = {
    enable = true;
    # Disable deprecated default config (will be removed in future home-manager)
    enableDefaultConfig = false;
    matchBlocks = {
      # Default settings for all hosts
      "*" = {
        identitiesOnly = true;
      };
      # GitHub specific
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };
}
