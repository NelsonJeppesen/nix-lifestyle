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
      (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "polaroid" ]; })
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

  # programs.steam = {
  #   enable = true;
  # };
}
