# TEAM_426: Audio configuration (PipeWire)
{ config, lib, pkgs, ... }:

{
  # Disable PulseAudio (we use PipeWire)
  services.pulseaudio.enable = false;

  # Enable rtkit for real-time audio
  security.rtkit.enable = true;

  # PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;  # PulseAudio compatibility
    jack.enable = true;   # JACK compatibility
    wireplumber.enable = true;
  };
}
