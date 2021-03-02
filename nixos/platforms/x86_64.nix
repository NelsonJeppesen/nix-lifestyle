{ config, pkgs, stdenv, lib, ... }:

{

  # vulkan 32bit and 64bit
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;

  hardware.pulseaudio.enable = true;
  sound.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  virtualisation.docker.enable = true;

  services.fstrim = {
    enable = true;
  };

  #services.printing.enable = true;
  #services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin];

  # Enable the GNOME 3 Desktop Environment.
  services.xserver = {
    enable = true;
    desktopManager.gnome3.enable = true;
    displayManager.gdm.enable = true;
    libinput.touchpad.accelProfile = "flat";
  };

  environment.gnome3.excludePackages = with pkgs; [
    gnome3.gnome-music
    gnome3.cheese
    gnome3.gnome-contacts
    gnome3.geary
  ];

  # Configure keymap in X11
  services.xserver.layout = "us";
}
