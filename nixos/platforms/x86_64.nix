{ config, pkgs, stdenv, lib, ... }:

{
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;
  sound.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  services.fstrim = {
    enable = true;
  };

  #services.printing.enable = true;
  #services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin];

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC    = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT   = "powersave";
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
      SATA_LINKPWR_ON_AC            = "min_power";
      SATA_LINKPWR_ON_BAT           = "min_power";
      CPU_BOOST_ON_AC               = "1";
      CPU_BOOST_ON_BAT              = "0";
    };
  };

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
