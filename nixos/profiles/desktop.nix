{ config, pkgs, stdenv, lib, ... }:

{
  services.resolved.enable = false;
  services.power-profiles-daemon.enable = false;
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

  # Pipewire stack with alsa/pulseaudio compat
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  # vulkan 32bit and 64bit
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  # Enable the GNOME 3 Desktop Environment.
  services.xserver = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    libinput.touchpad.accelProfile = "flat";
    libinput.touchpad.tappingDragLock = false;
    libinput.touchpad.tapping = false;
    enable = true;
  };

  services.gnome.gnome-online-accounts.enable = false;
  services.gnome.gnome-remote-desktop.enable = false;
  services.gnome.gnome-initial-setup.enable = false;
  services.gnome.gnome-user-share.enable = false;
  #hardware.logitech.wireless.enable = true;

  #services.printing.enable = true;
  #services.printing.drivers = [ pkgs.hplip];
  #hardware.sane.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome.cheese
    gnome.geary
    gnome.gnome-backgrounds
    gnome.gnome-contacts
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

  system.stateVersion = "20.09"; # Did you read the comment?
}
