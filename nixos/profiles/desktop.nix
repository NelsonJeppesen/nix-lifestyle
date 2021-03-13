{ config, pkgs, stdenv, lib, ... }:

{
  hardware.pulseaudio.enable = true;
  sound.enable = true;

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
  ];

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Open KDE Connect
  networking.firewall.allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
  networking.firewall.allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];

  system.stateVersion = "20.09"; # Did you read the comment?
}
