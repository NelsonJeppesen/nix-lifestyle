{ pkgs, ... }:
{
  services = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    gnome = {
      games.enable = false;
      gnome-initial-setup.enable = false;
      rygel.enable = false;
      sushi.enable = false;
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
  ];
}
