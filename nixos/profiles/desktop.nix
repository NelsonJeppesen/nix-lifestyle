{ config, pkgs, stdenv, lib, ... }:
{
  # The start of the week *should* be Monday
  i18n.extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };

  system.activationScripts.setGnomeProfilePicture = ''
    mkdir -p /var/lib/AccountsService/icons
    if [[ ! -h /var/lib/AccountsService/icons/nelson ]]; then
      cp /etc/nixos/nelson.jpeg /var/lib/AccountsService/icons/nelson
    fi
  '';

  hardware.bluetooth.enable = true;

  # Pipewire
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    alsa.enable = true;
    enable = true;
    pulse.enable = true;
  };

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    layout = "us";
    libinput = { touchpad.tapping = false; };
  };

  services.gnome.gnome-initial-setup.enable = false;
  services.gnome.sushi.enable = false;
  services.gnome.rygel.enable = false;
  services.gnome.games.enable = false;

  #services.printing.enable   = true;
  #services.printing.drivers  = [ pkgs.hplip];
  #hardware.sane.enable       = true;

  # Remove gnome tools I don't use
  environment.gnome.excludePackages = with pkgs.gnome; [
    gnome-backgrounds
    gnome-maps
    gnome-music
    pkgs.gnome-tour
    pkgs.gnome-user-docs
    pkgs.gnome-video-effects
  ];

}
