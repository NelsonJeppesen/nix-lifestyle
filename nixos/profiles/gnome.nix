{ config, pkgs, stdenv, lib, ... }: {
  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    xkb.layout = "us";
  };
  services.libinput = { touchpad.tapping = false; };
  services.gnome.gnome-initial-setup.enable = false;
  services.gnome.sushi.enable = false;
  services.gnome.rygel.enable = false;
  services.gnome.games.enable = false;

  # Remove gnome tools I don't use
  environment.gnome.excludePackages = with pkgs.gnome; [
    pkgs.gnome-backgrounds
    pkgs.gnome-maps
    pkgs.gnome-music
    pkgs.gnome-tour
    pkgs.gnome-user-docs
    pkgs.gnome-video-effects
  ];
}
