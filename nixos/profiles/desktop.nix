{ config, pkgs, stdenv, lib, ... }:
{
  hardware.bluetooth.enable = true;

  # Pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    alsa.enable = true;
    enable = true;
    pulse.enable = true;
  };
}
