# TEAM_426: Vince user configuration (system-level)
{ config, lib, pkgs, ... }:

{
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

  # Link to Home Manager configuration
  home-manager.users.vince = import ../../home/vince;
}
