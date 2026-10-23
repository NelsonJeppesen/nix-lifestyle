# desktop.nix - Workstation/laptop baseline (audio, BT, boot, splash)
#
# Sets up:
# - Logitech wireless (Solaar), Bluetooth, PipeWire (replaces PulseAudio)
# - systemd-boot loader with high console mode
# - Quiet boot kernel params so the splash owns the screen end-to-end
#
# Machines import chrome-policies.nix, console.nix and plymouth.nix beside
# this one; profiles stay leaf (nixos/AGENTS.md).
{ pkgs, ... }:
{
  hardware.logitech.wireless = {
    enable = true;
  };
  programs.solaar.enable = true;

  hardware.bluetooth.enable = true;
  services.pulseaudio.enable = false;
  programs.evolution.enable = false;

  boot.loader.systemd-boot.configurationLimit = 14;
  # `max` picks the firmware's largest GOP mode, which on a HiDPI panel
  # shrinks the fixed-size firmware glyph to ant-size. `auto` lets sd-boot
  # pick a sensibly-sized mode (override per-host with a specific index if
  # the auto pick is still off).
  boot.loader.systemd-boot.consoleMode = "auto";
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.enable = true;

  # Quiet boot: suppress kernel + udev chatter so Plymouth owns the screen
  # from initrd through to the display manager. `quiet` lowers the kernel
  # printk level; `boot.consoleLogLevel = 3` below adds `loglevel=3`, which
  # keeps errors+ visible on real failures, and the Plymouth module adds
  # `splash`. `udev.log_level=3` silences udev's own info spam.
  # `rd.systemd.show_status` and `rd.udev.log_level` cover the initrd side.
  # `vt.global_cursor_default` hides the TTY cursor underneath the splash.
  # `fbcon=nodefer` prevents the framebuffer console from briefly grabbing
  # the screen before Plymouth.
  boot.kernelParams = [
    "quiet"
    "rd.systemd.show_status=auto"
    "rd.udev.log_level=3"
    "udev.log_level=3"
    "vt.global_cursor_default=0"
    "fbcon=nodefer"
  ];
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

  # Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    alsa.enable = true;
    audio.enable = true;
    enable = true;
    pulse.enable = true;
  };
}
