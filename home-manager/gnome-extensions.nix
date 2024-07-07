{
  config,
  lib,
  pkgs,
  ...
}:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.caffeine; }
      { package = pkgs.gnomeExtensions.clipboard-indicator; }
      { package = pkgs.gnomeExtensions.ddterm; }
      { package = pkgs.gnomeExtensions.hue-lights; }
      { package = pkgs.gnomeExtensions.just-perfection; }
      { package = pkgs.gnomeExtensions.light-style; }
      { package = pkgs.gnomeExtensions.night-theme-switcher; }
      { package = pkgs.gnomeExtensions.one-thing; }
      { package = pkgs.gnomeExtensions.picture-of-the-day; }
      { package = pkgs.gnomeExtensions.pip-on-top; }
      { package = pkgs.gnomeExtensions.run-or-raise; }
      { package = pkgs.gnomeExtensions.unblank; }

      # "Play lofi music on your Gnome desktop with just a click!"
      #   https://github.com/eucaue/gnome-shell-extension-quick-lofi
      { package = pkgs.gnomeExtensions.quick-lofi; }
    ];
  };

  dconf.settings = {

    # https://github.com/rafaelmardojai/blanket
    #   "Improve focus and increase your productivity by listening to different
    #   sounds. Or allows you to fall asleep in a noisy environment"
    "com/rafaelmardojai/Blanket" = {
      autostart = false;
      background-playback = true;
      start-paused = false;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      dash = false;
      search = true;
      startup-status = 0; # disable the overview popup thing
      theme = false;
      window-maximized-on-create = true;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      cache-size = 10;
      disable-down-arrow = false;
      display-mode = 0;
      history-size = 200;
      strip-text = true;
      topbar-preview-size = 8;

      clear-history = [ ];
      next-entry = [ "<Shift><Control>p" ];
      prev-entry = [ "<Shift><Control>o" ];
      private-mode-binding = [ ];
      toggle-menu = [ "<Shift><Control>i" ];
    };

    "org/gnome/shell/extensions/quick-lofi" = {
      volume = 75;
      radios = [
        # somafm
        "SomaFM DEF CON - http://somafm.com/defcon130.pls"
        "SomaFM Doomed - http://somafm.com/doomed130.pls"
        "SomaFM Drone Zone - http://somafm.com/dronezone130.pls"
        "SomaFM Groove Salad - http://somafm.com/groovesalad130.pls"
        "SomaFM SF 10-33 - http://somafm.com/sf1033130.pls"
        "SomaFM Space Station - http://somafm.com/spacestation130.pls"
        "SomaFM Synphaera - http://somafm.com/synphaera130.pls"
        "SomaFM Vaporwaves - http://somafm.com/vaporwaves130.pls"

        # "radio"
        "KALW - https://kalw-live.streamguys1.com/kalw.aac"
        "KEXP - https://kexp-mp3-128.streamguys1.com/kexp128.mp3"

        # rekt.network
        "rekt: chillsynth - http://stream.rekt.network/chillsynth.ogg"
        "rekt: darksynth - http://stream.rekt.network/darksynth.ogg"
        "rekt: datawave - http://stream.rekt.network/datawave.ogg"
        "rekt: ebsm - http://stream.rekt.network/ebsm.ogg"
        "rekt: horrorsynth - http://stream.rekt.network/horrorsynth.ogg"
        "rekt: nightride - http://stream.rekt.network/nightride.ogg"
        "rekt: rekt - http://stream.rekt.network/rekt.ogg"
        "rekt: rektory - http://stream.rekt.network/rektory.ogg"
        "rekt: spacesynth - http://stream.rekt.network/spacesynth.ogg"

        "[emergency slow internet] - http://somafm.com/defcon32.pls"
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
      toggle-shortcut = [ "<Super>c" ];
    };

    "org/gnome/shell/extensions/github-notifications" = {
      handle = "NelsonJeppesen";
      hide-widget = true;
      refresh-interval = 61;
    };

    "org/gnome/shell/extensions/nightthemeswitcher/commands" = {
      enabled = true;
      sunset = "/home/nelson/kitty-colorscheme";
      sunrise = "/home/nelson/kitty-colorscheme";
    };

    "org/gnome/shell/extensions/nightthemeswitcher/shell-variants" = {
      enabled = true;
      day = "LightShell";
      night = "";
    };

    "org/gnome/shell/extensions/one-thing" = {
      index-in-status-bar = 1;
      location-in-status-bar = 0;
      show-settings-button-on-popup = false;
    };

    #"org/gnome/shell/extensions/pano" = {
    #  history-length = 500;
    #  keep-search-entry = false;
    #  open-links-in-browser = false;
    #  play-audio-on-copy = false;
    #  send-notification-on-copy = false;
    #  show-indicator = false;
    #  window-position = lib.hm.gvariant.mkUint32 (1); # right side of the screen
    #};

    #"org/gnome/shell/extensions/pano/text-item" = {
    #  body-bg-color = "rgb(153,193,241)";
    #};

    "org/gnome/shell/extensions/unblank" = {
      power = false;
      time = 1800;
    };

    # drop down terminal used to chatgpt
    "com/github/amezin/ddterm" = {
      audible-bell = false;
      background-color = "rgb(46,52,54)";
      backspace-binding = "auto";
      bold-color-same-as-fg = true;
      bold-is-bright = true;
      command = "custom-command";
      custom-command = "zsh -ceil -- 'cd /home/nelson/source/personal;/home/nelson/.nix-profile/bin/chatgpt'";
      custom-font = "B612 Mono 13";
      ddterm-toggle-hotkey = [ "<Super>t" ];
      foreground-color = "rgb(255,255,255)";
      hide-when-focus-lost = true;
      new-tab-button = false;
      notebook-border = false;
      override-window-animation = false;
      panel-icon-type = "none";
      scroll-on-output = true;
      scrollback-lines = 10002;
      shortcut-font-scale-decrease = [ "<Primary>underscore" ];
      shortcut-font-scale-increase = [ "<Primary>plus" ];
      shortcuts-enabled = true;
      show-animation = "ease-in-out-back";
      show-animation-duration = 0.2;
      show-scrollbar = false;
      tab-close-buttons = false;
      tab-expand = false;
      tab-label-ellipsize-mode = "middle";
      tab-label-width = 0.1;
      tab-policy = "automatic";
      tab-position = "top";
      tab-switcher-popup = false;
      text-blink-mode = "focused";
      transparent-background = true;
      use-system-font = false;
      use-theme-colors = false;
      window-above = true;
      window-maximize = false;
      window-monitor = "primar";
      window-position = "right";
      window-resizable = false;
      window-size = 0.45;
      window-skip-taskbar = false;
    };
  };
}
