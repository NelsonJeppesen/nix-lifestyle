# desktop.nix - Workstation/laptop baseline (audio, BT, boot, splash)
#
# Imports chrome-policies for declarative Chrome management. Sets up:
# - Logitech wireless (Solaar), Bluetooth, PipeWire (replaces PulseAudio)
# - systemd-boot loader with high console mode
# - Plymouth `polaroid` splash, patched for 1-frame-per-tick smoothness
# - Quiet boot kernel params so the splash owns the screen end-to-end
{ pkgs, ... }:
{
  imports = [ ./chrome-policies.nix ];

  hardware.logitech.wireless = {
    enable = true;
    enableGraphical = true;
  };

  hardware.bluetooth.enable = true;
  services.pulseaudio.enable = false;
  programs.evolution.enable = false;

  boot.loader.systemd-boot.configurationLimit = 14;
  boot.loader.systemd-boot.consoleMode = "max";
  boot.loader.systemd-boot.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "polaroid";
    themePackages = [
      # Patch the polaroid script for the smoothest possible animation:
      # display every frame, one per refresh tick. Upstream uses
      # `Math.Int(progress/2)` with `progress++`, showing each frame for
      # 2 ticks (~50Hz → ~15s/cycle, visibly slow). Dropping the divisor
      # and keeping `progress++` advances exactly 1 frame/tick — every
      # frame shown, no skips, no rounding jitter (~7.5s/cycle, ~2x).
      # This is the maximum speed achievable without skipping frames.
      (
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "polaroid" ];
        }).overrideAttrs
        (old: {
          postPatch = (old.postPatch or "") + ''
            substituteInPlace polaroid/polaroid.script \
              --replace-fail "Math.Int(progress / 2) % 392" "progress % 392"
          '';
        })
      )
    ];
  };

  # Quiet boot: suppress kernel + udev chatter so Plymouth owns the screen
  # from initrd through to the display manager. `quiet` lowers the kernel
  # printk level; `loglevel=3` keeps errors+ visible on real failures.
  # `udev.log_level=3` silences udev's own info spam. `rd.systemd.show_status`
  # and `rd.udev.log_level` cover the initrd side. `vt.global_cursor_default`
  # hides the TTY cursor underneath the splash. `fbcon=nodefer` prevents the
  # framebuffer console from briefly grabbing the screen before Plymouth.
  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
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
