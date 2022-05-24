{ config, pkgs, stdenv, lib, ... }:

{
  services.resolved.enable = true;
  services.power-profiles-daemon.enable = false; # I'm using TLP right now

  # The start of the week *should* be Monday, not Sunday
  i18n.extraLocaleSettings = {
    LC_TIME = "en_GB.UTF-8";
  };

  system.activationScripts.setGnomeProfilePicture = ''
    mkdir -p /var/lib/AccountsService/icons
    if [[ ! -h /var/lib/AccountsService/icons/nelson ]]; then
      cp /etc/nixos/nelson.jpeg /var/lib/AccountsService/icons/nelson
    fi
  '';

  hardware.bluetooth.enable = true;
  programs.gpaste.enable = true;
  programs.steam.enable = true;

  # Pipewire stack with alsa/pulseaudio compat
  # Pipewire is the future
  sound.enable = true;
  hardware.pulseaudio.enable = false; # Use pipewire with pulse compat
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true; # Steam support
  services.pipewire.enable = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;

  # vulkan 32bit and 64bit
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true; # Steam support

  services.xserver = {
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
    #= {
    # Optionally, set a default session
    #windowManager = {
    #    default = "awesome";
    #    awesome.enable = true;
    #};

#services.greetd = {
#    enable = true;
#    settings = {
#      default_session = {
#        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'dbus-run-session -- gnome-shell --display-server --wayland'";
#        user = "nelson";
#      };
#    };
#  };

  services.xserver.libinput.touchpad.accelProfile = "adaptive";
  services.xserver.libinput.touchpad.accelSpeed = "0.4";

  #services.xserver.libinput.touchpad.tappingDragLock = false; # make less gltichy
  services.xserver.libinput.touchpad.tapping = false; # make less gltichy

  services.gnome.gnome-initial-setup.enable = false;
  #services.gnome.gnome-online-accounts.enable = false;
  #services.gnome.gnome-online-miners.enable   = false;
  #services.gnome.gnome-remote-desktop.enable  = false;
  #services.gnome.gnome-user-share.enable      = false;
  #services.gnome.tracker.enable               = false;
  #services.gnome.rygel.enable                 = false;
  #hardware.logitech.wireless.enable           = true;

  #services.printing.enable   = true;
  #services.printing.drivers  = [ pkgs.hplip];
  #hardware.sane.enable       = true;

  # Remove gnome tools I don't use
  #environment.gnome.excludePackages = with pkgs.gnome; [
  #  pkgs.gnome-online-accounts
  #  pkgs.gnome-tour
  #  pkgs.gnome-user-docs
  #  pkgs.gnome-video-effects
  #  gnome-backgrounds
  #  gnome-calendar
  #  gnome-contacts
  #  gnome-disk-utility
  #  gnome-logs
  #  gnome-maps
  #  gnome-music
  #  gnome-online-miners
  #  gnome-screenshot
  #  gnome-weather
  #];

  # Configure keymap in X11
  services.xserver.layout = "us";

  # Open KDE Connect
  networking.firewall.allowedTCPPortRanges = [{ from = 1714; to = 1764; }];
  networking.firewall.allowedUDPPortRanges = [{ from = 1714; to = 1764; }];

  system.stateVersion = lib.mkDefault "21.05"; # Did you read the comment?
}
