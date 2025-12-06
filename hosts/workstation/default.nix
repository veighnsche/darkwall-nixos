# TEAM_434: workstation - Headless GPU server
# Intel i7-6850K, 80GB RAM, RTX 3090 + RTX 3060
# Service accounts only - no interactive users
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./storage.nix                    # LVM models storage
    ../../modules/system/server.nix  # Headless server config
  ];

  networking.hostName = "workstation";

  # ════════════════════════════════════════════════════════════════
  # Boot Configuration
  # ════════════════════════════════════════════════════════════════
  
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # ════════════════════════════════════════════════════════════════
  # NVIDIA GPUs
  # ════════════════════════════════════════════════════════════════
  
  hardware.graphics.enable = true;
  
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;  # Server - always on
    open = false;  # Use proprietary driver for CUDA
    nvidiaSettings = false;  # No GUI
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # CUDA support
  environment.systemPackages = with pkgs; [
    cudaPackages.cudatoolkit
    nvtopPackages.nvidia
  ];

  
  # ════════════════════════════════════════════════════════════════
  # Admin Access (SSH only)
  # ════════════════════════════════════════════════════════════════
  
  # Admin user for SSH management (no desktop, minimal home)
  users.users.admin = {
    isNormalUser = true;
    description = "Server administrator";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key
      # "ssh-ed25519 AAAA... admin@blep"
    ];
    # No password - SSH key only
    hashedPassword = null;
  };
  
  # Disable password auth - SSH keys only
  services.openssh.settings.PasswordAuthentication = false;

  # ════════════════════════════════════════════════════════════════
  # Firewall
  # ════════════════════════════════════════════════════════════════
  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      22      # SSH
      8188    # ComfyUI web UI
    ];
  };

  # ════════════════════════════════════════════════════════════════
  # Podman + NVIDIA Container Runtime
  # ════════════════════════════════════════════════════════════════
  
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # docker CLI compatibility
    defaultNetwork.settings.dns_enabled = true;
  };
  
  hardware.nvidia-container-toolkit.enable = true;

  # ════════════════════════════════════════════════════════════════
  # ComfyUI Service User
  # ════════════════════════════════════════════════════════════════
  
  users.users.comfyui = {
    isSystemUser = true;
    group = "comfyui";
    home = "/var/lib/comfyui";
    createHome = true;
    description = "ComfyUI service account";
  };
  users.groups.comfyui = {};

  # ════════════════════════════════════════════════════════════════
  # ComfyUI Container
  # ════════════════════════════════════════════════════════════════
  # 
  # Architecture:
  #   - Models on LVM: /mnt/models (persistent, huge, shared)
  #   - ComfyUI workspace: /var/lib/comfyui (mutable, updatable via Manager)
  # 
  # Management:
  #   - Update ComfyUI: use ComfyUI Manager inside the web UI
  #   - View logs: journalctl -u podman-comfyui -f
  #   - Restart: systemctl restart podman-comfyui
  #   - Shell into container: podman exec -it comfyui bash
  # 
  # ════════════════════════════════════════════════════════════════
  
  virtualisation.oci-containers = {
    backend = "podman";
    containers.comfyui = {
      image = "ghcr.io/ai-dock/comfyui:pytorch-2.4.1-py3.11-cuda-12.4.1-runtime-22.04";
      autoStart = true;
      
      ports = [ "8188:8188" ];
      
      volumes = [
        # ComfyUI workspace (code, custom nodes, output) - mutable
        "/var/lib/comfyui:/workspace/ComfyUI:rw"
        # Models from LVM - persistent, shared
        # TEAM_435: All model directories per ComfyUI docs
        "/mnt/models/checkpoints:/workspace/ComfyUI/models/checkpoints:rw"
        "/mnt/models/clip:/workspace/ComfyUI/models/clip:rw"
        "/mnt/models/clip_vision:/workspace/ComfyUI/models/clip_vision:rw"
        "/mnt/models/configs:/workspace/ComfyUI/models/configs:rw"
        "/mnt/models/controlnet:/workspace/ComfyUI/models/controlnet:rw"
        "/mnt/models/diffusers:/workspace/ComfyUI/models/diffusers:rw"
        "/mnt/models/embeddings:/workspace/ComfyUI/models/embeddings:rw"
        "/mnt/models/gligen:/workspace/ComfyUI/models/gligen:rw"
        "/mnt/models/hypernetworks:/workspace/ComfyUI/models/hypernetworks:rw"
        "/mnt/models/loras:/workspace/ComfyUI/models/loras:rw"
        "/mnt/models/style_models:/workspace/ComfyUI/models/style_models:rw"
        "/mnt/models/unet:/workspace/ComfyUI/models/unet:rw"
        "/mnt/models/upscale_models:/workspace/ComfyUI/models/upscale_models:rw"
        "/mnt/models/vae:/workspace/ComfyUI/models/vae:rw"
        "/mnt/models/vae_approx:/workspace/ComfyUI/models/vae_approx:rw"
      ];
      
      # GPU access + container hardening
      extraOptions = [
        "--device=nvidia.com/gpu=all"
        "--security-opt=label=disable"
        # Health check - verify web UI responds
        "--health-cmd=curl -f http://localhost:8188/ || exit 1"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=3"
        "--health-start-period=60s"
        # Resource limits (prevent runaway)
        "--memory=64g"
        "--shm-size=8g"
        # Logging
        "--log-driver=journald"
        "--log-opt=tag=comfyui"
      ];
      
      environment = {
        NVIDIA_VISIBLE_DEVICES = "all";
        NVIDIA_DRIVER_CAPABILITIES = "all";
        # Reduce Python buffering for better log visibility
        PYTHONUNBUFFERED = "1";
      };
    };
  };
  
  # TEAM_435: Systemd overrides for ComfyUI container
  systemd.services.podman-comfyui = {
    serviceConfig = {
      # OCI module sets "always", we prefer "on-failure" to avoid restart loops
      Restart = lib.mkForce "on-failure";
      RestartSec = "10s";
    };
    # Wait for models volume to be mounted
    after = [ "mnt-models.mount" ];
    requires = [ "mnt-models.mount" ];
  };
}
