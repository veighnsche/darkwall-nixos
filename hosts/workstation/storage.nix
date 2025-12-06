# TEAM_434: LVM storage configuration for AI models
# 4x 250GB SSDs in LVM volume group vg_models
{ ... }:

{
  # Ensure LVM is activated in initrd
  boot.initrd.services.lvm.enable = true;

  # Mount LVM volume for AI models
  fileSystems."/mnt/models" = {
    device = "/dev/vg_models/lv_models";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nofail" "x-systemd.device-timeout=30" ];
  };

  # Ensure models directory structure exists
  # TEAM_435: All model directories per ComfyUI docs, owned by comfyui user
  systemd.tmpfiles.rules = [
    # Model directories on LVM (alphabetical order)
    "d /mnt/models/checkpoints 0755 comfyui comfyui -"
    "d /mnt/models/clip 0755 comfyui comfyui -"
    "d /mnt/models/clip_vision 0755 comfyui comfyui -"
    "d /mnt/models/configs 0755 comfyui comfyui -"
    "d /mnt/models/controlnet 0755 comfyui comfyui -"
    "d /mnt/models/diffusers 0755 comfyui comfyui -"
    "d /mnt/models/embeddings 0755 comfyui comfyui -"
    "d /mnt/models/gligen 0755 comfyui comfyui -"
    "d /mnt/models/hypernetworks 0755 comfyui comfyui -"
    "d /mnt/models/loras 0755 comfyui comfyui -"
    "d /mnt/models/style_models 0755 comfyui comfyui -"
    "d /mnt/models/unet 0755 comfyui comfyui -"
    "d /mnt/models/upscale_models 0755 comfyui comfyui -"
    "d /mnt/models/vae 0755 comfyui comfyui -"
    "d /mnt/models/vae_approx 0755 comfyui comfyui -"
    # ComfyUI workspace
    "d /var/lib/comfyui 0755 comfyui comfyui -"
    "d /var/lib/comfyui/output 0755 comfyui comfyui -"
    "d /var/lib/comfyui/input 0755 comfyui comfyui -"
    "d /var/lib/comfyui/custom_nodes 0755 comfyui comfyui -"
  ];
}
