{ config, pkgs, stdenv, lib, ... }:

{
  sound.enable = true;

  # vulkan 32bit and 64bit
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.package = pkgs.pulseaudioFull;

  # Enable the GNOME 3 Desktop Environment.
  services.xserver = {
    desktopManager.gnome3.enable = true;
    displayManager.gdm.enable = true;
    libinput.touchpad.accelProfile = "flat";
    enable = true;
  };

  #services.printing.enable = true;
  #services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin];

  environment.gnome3.excludePackages = with pkgs; [
    gnome3.gnome-music
    gnome3.cheese
    gnome3.gnome-contacts
    gnome3.geary
    gnome3.gnome-backgrounds
    gnome3.gnome-getting-started-docs
    gnome3.gnome-user-docs
    gnome3.gnome-maps
    gnome3.gnome-logs
    gnome3.gnome-screenshot
    gnome3.gnome-weather
    gnome3.gnome-online-accounts
    gnome3.gnome-online-miners
  ];

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Open KDE Connect
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  system.stateVersion = "20.09"; # Did you read the comment?
}
