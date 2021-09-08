{ config, pkgs, stdenv, lib, ... }:

{
  services.resolved.enable = true;
  services.power-profiles-daemon.enable = false; # I'm using TLP right now
  #services.ddccontrol.enable = true;

  # The start of the week *should* be Monday, not Sunday
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
  };

  hardware.i2c.enable = true;
  hardware.i2c.group = "users";

  hardware.bluetooth.enable = true;

  programs.gpaste.enable = true;
  programs.steam.enable = true;

  sound.enable = true;

  # Pipewire stack with alsa/pulseaudio compat
  # Pipewire is the future
  hardware.pulseaudio.enable            = false;  # Use pipewire with pulse compat
  services.pipewire.alsa.enable         = true;
  services.pipewire.alsa.support32Bit   = true;   # Steam support
  services.pipewire.enable              = true;
  services.pipewire.pulse.enable        = true;

  # vulkan 32bit and 64bit
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true; # Steam support

  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.enable   = true;

  services.xserver.libinput.touchpad.accelProfile    = "flat";
  services.xserver.libinput.touchpad.tappingDragLock = false; # make less gltichy
  services.xserver.libinput.touchpad.tapping         = false; # make less gltichy

  services.gnome.gnome-initial-setup.enable   = false;
  services.gnome.gnome-online-accounts.enable = false;
  #services.gnome.gnome-online-miners.enable   = false;
  services.gnome.gnome-remote-desktop.enable  = false;
  services.gnome.gnome-user-share.enable      = false;
  services.gnome.tracker.enable               = false;
  services.gnome.rygel.enable                 = false;
  #hardware.logitech.wireless.enable           = true;

  #services.printing.enable   = true;
  #services.printing.drivers  = [ pkgs.hplip];
  #hardware.sane.enable       = true;

  # Remove gnome tools I don't use
  environment.gnome.excludePackages = with pkgs; [
    gnome.cheese
    gnome.geary
    gnome.gnome-backgrounds
    gnome.gnome-contacts
    gnome.gnome-calendar
    gnome.gnome-logs
    gnome.gnome-maps
    gnome.gnome-music
    gnome.gnome-screenshot
    gnome.gnome-user-docs
    gnome.gnome-weather
    gnome.gnome-online-accounts
    gnome.gnome-online-miners
  ];

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Open KDE Connect
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  system.stateVersion = "21.05"; # Did you read the comment?
}
