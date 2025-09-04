{ pkgs, ... }:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.bitcoin-markets; }
      { package = pkgs.gnomeExtensions.caffeine; }
      { package = pkgs.gnomeExtensions.clipboard-indicator; }
      { package = pkgs.gnomeExtensions.just-perfection; }
      { package = pkgs.gnomeExtensions.picture-of-the-day; }
      { package = pkgs.gnomeExtensions.run-or-raise; }

      # "Play lofi music on your Gnome desktop with just a click!"
      #   https://github.com/eucaue/gnome-shell-extension-quick-lofi
      { package = pkgs.gnomeExtensions.quick-lofi; }
    ];
  };

  dconf.settings = {

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false;
      dash = false;
      search = true;
      startup-status = 0; # disable the overview popup thing
      theme = false;
      window-maximized-on-create = true;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      cache-size = 10;
      clear-history = [ ];
      disable-down-arrow = true;
      display-mode = 1;
      history-size = 200;
      move-item-first = true;
      next-entry = [ "<Shift><Control>p" ];
      paste-button = false;
      prev-entry = [ "<Shift><Control>o" ];
      private-mode-binding = [ ];
      strip-text = true;
      toggle-menu = [ "<Shift><Control>i" ];
      topbar-preview-size = 9;
    };

    "org/gnome/shell/extensions/quick-lofi" = {
      volume = 75;
      set-popup-max-height = false;

      radios = [
        # SomaFM Radios
        "SomaFM DEF CON - http://somafm.com/defcon130.pls"
        "SomaFM Dark Zone - http://somafm.com/darkzone130.pls"
        "SomaFM Drone Zone - http://somafm.com/dronezone130.pls"
        "SomaFM Groove Salad - http://somafm.com/groovesalad130.pls"
        "SomaFM SF 10-33 - http://somafm.com/sf1033130.pls"
        "SomaFM Space Station - http://somafm.com/spacestation130.pls"
        "SomaFM Synphaera - http://somafm.com/synphaera130.pls"
        "SomaFM Vaporwaves - http://somafm.com/vaporwaves130.pls"

        # General Radios
        "KALW - https://kalw-live.streamguys1.com/kalw.aac"
        "KEXP - https://kexp-mp3-128.streamguys1.com/kexp128.mp3"

        # rekt.network Radios
        "rekt: chillsynth - http://stream.rekt.network/chillsynth.ogg"
        "rekt: darksynth - http://stream.rekt.network/darksynth.ogg"
        "rekt: datawave - http://stream.rekt.network/datawave.ogg"
        "rekt: ebsm - http://stream.rekt.network/ebsm.ogg"
        "rekt: horrorsynth - http://stream.rekt.network/horrorsynth.ogg"
        "rekt: nightride - http://stream.rekt.network/nightride.ogg"
        "rekt: rekt - http://stream.rekt.network/rekt.ogg"
        "rekt: rektory - http://stream.rekt.network/rektory.ogg"
        "rekt: spacesynth - http://stream.rekt.network/spacesynth.ogg"
      ];
    };

    "org/gnome/shell/extensions/swsnr-picture-of-the-day" = {
      selected-source = "bing";
    };

    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = -0.1;
      icon-opacity = 255;
      icon-saturation = 0.8;
      icon-size = 18;
      tray-pos = "right";
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position = -1;
      indicator-position-index = -1;
      screen-blank = "never";
      show-indicator = "only-active";
      show-notifications = false;
      toggle-shortcut = [ "<Super>p" ];
    };
  };
}
