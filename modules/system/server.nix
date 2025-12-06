# TEAM_434: Headless server configuration
# Shared by workstation and infra hosts
{ config, lib, pkgs, ... }:

{
  # No desktop environment
  services.xserver.enable = lib.mkDefault false;
  
  # Prevent sleep/suspend on servers
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  
  # Enable serial console for remote debugging
  boot.kernelParams = [ "console=ttyS0,115200" ];
  
  # Headless boot (no splash, no quiet)
  boot.plymouth.enable = false;
  boot.consoleLogLevel = 3;
  
  # Server-oriented packages
  environment.systemPackages = with pkgs; [
    tmux           # Terminal multiplexer
    btop           # Resource monitor
    iotop          # IO monitor
    ncdu           # Disk usage analyzer
    rsync          # File sync
    jq             # JSON processor
  ];
  
  # Enable fail2ban for SSH protection
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
  };
  
  # Automatic security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;  # Manual reboot for servers
  };
}
