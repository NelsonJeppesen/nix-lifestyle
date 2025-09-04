{ lib, pkgs, ... }:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    gnome = {
      evolution-data-server.enable = lib.mkForce false;
      games.enable = false;
      gcr-ssh-agent.enable = false;
      gnome-browser-connector.enable = false;
      gnome-initial-setup.enable = false;
      gnome-online-accounts.enable = lib.mkForce false;
      gnome-remote-desktop.enable = false;
      localsearch.enable = false;
      rygel.enable = false;
      sushi.enable = false;
      tinysparql.enable = false;
    };

    xserver = {
      enable = true;
      xkb.layout = "us";
    };
  };

  # Remove gnome tools I don't use
  environment.gnome.excludePackages = [
    pkgs.gnome-backgrounds
    pkgs.gnome-maps
    pkgs.gnome-music
    pkgs.gnome-tour
    pkgs.gnome-user-docs
    pkgs.gnome-video-effects
    pkgs.gnome-weather
    pkgs.gnome-calculator
    pkgs.gnome-contacts
    pkgs.gnome-logs
  ];
}
