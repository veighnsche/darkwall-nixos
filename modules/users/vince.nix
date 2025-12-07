# TEAM_426: Vince user configuration (system-level)
# TEAM_445: Added flake repo bootstrap for dotfile symlinks
{ config, lib, pkgs, self, ... }:

let
  # TEAM_445: Path where dotfile symlinks expect the flake repo
  flakeRepoPath = "/home/vince/Projects/darkwall-nixos";
in {
  users.users.vince = {
    isNormalUser = true;
    description = "Vince";
    extraGroups = [
      "wheel"           # sudo access
      "networkmanager"  # network management
      "video"           # GPU access
      "audio"           # audio devices
      "input"           # input devices
      "docker"          # docker (if enabled)
    ];

    # Password is set per-host (see hosts/*/default.nix)
    # For production, use: initialHashedPassword = "..." (generate with mkpasswd -m sha-512)

    # SSH keys for remote access
    openssh.authorizedKeys.keys = [
      # Add your public key here
      # "ssh-ed25519 AAAA... vince@machine"
    ];
  };

  # TEAM_445: Bootstrap flake repo on first boot so dotfile symlinks resolve
  # This copies the flake source into the expected location if it doesn't exist
  # NOTE: SSH key for git push must be set up separately (see secrets management below)
  system.activationScripts.bootstrapFlakeRepo = lib.stringAfter [ "users" ] ''
    if [ ! -d "${flakeRepoPath}" ]; then
      echo "══════════════════════════════════════════════════════════════"
      echo "  BOOTSTRAPPING FLAKE REPO"
      echo "══════════════════════════════════════════════════════════════"
      
      # Create directory structure
      mkdir -p "${flakeRepoPath}"
      
      # Copy flake contents (not the store path itself, but its contents)
      cp -rT ${self} "${flakeRepoPath}"
      
      # Initialize git with remote already configured
      cd "${flakeRepoPath}"
      ${pkgs.git}/bin/git init
      ${pkgs.git}/bin/git remote add origin git@github.com:veighnsche/darkwall-nixos.git
      ${pkgs.git}/bin/git add -A
      
      # Set ownership
      chown -R vince:users "${flakeRepoPath}"
      chmod -R u+w "${flakeRepoPath}"
      
      echo ""
      echo "  ✓ Flake repo bootstrapped to ${flakeRepoPath}"
      echo "  ✓ Git initialized with remote: git@github.com:veighnsche/darkwall-nixos.git"
      echo ""
      echo "  NEXT STEPS:"
      echo "  1. Set up SSH key for git push (see ~/.ssh/)"
      echo "  2. Run: cd ${flakeRepoPath} && git fetch origin && git branch -u origin/main"
      echo "══════════════════════════════════════════════════════════════"
    fi
  '';

  # TEAM_445: SSH key for git - managed via home-manager
  # The private key should be provisioned via one of:
  #   1. agenix/sops-nix (encrypted in repo, decrypted at activation)
  #   2. Manual copy after install
  #   3. SSH agent forwarding from another machine
  # 
  # To add agenix later:
  #   1. Add agenix to flake inputs
  #   2. Create secrets/ssh-key.age encrypted with your age key
  #   3. Reference via age.secrets.ssh-key.file

  # TEAM_448: Passwordless sudo for VM automation commands
  # nixos-rebuild: enables `just vm-rebuild` without password
  # poweroff: enables `just vm-stop` without password
  security.sudo.extraRules = [{
    users = [ "vince" ];
    commands = [
      { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
      { command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/poweroff"; options = [ "NOPASSWD" ]; }
      { command = "/run/current-system/sw/bin/reboot"; options = [ "NOPASSWD" ]; }
    ];
  }];

  # Link to Home Manager configuration
  home-manager.users.vince = import ../../home/vince;
}
