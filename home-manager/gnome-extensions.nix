{ config, lib, pkgs, ... }: {
  home.file.".config/run-or-raise/shortcuts.conf".source =
    ./dotfiles/shortcuts.conf;

  home.packages = [
    #pkgs.gnomeExtensions.bluetooth-quick-connect
    #pkgs.gnomeExtensions.blur-my-shell
    #pkgs.gnomeExtensions.gsconnect
    #pkgs.gnomeExtensions.just-perfection
    #pkgs.gnomeExtensions.media-controls
    #pkgs.gnomeExtensions.one-thing
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.ddterm
    pkgs.gnomeExtensions.github-actions
    pkgs.gnomeExtensions.google-earth-wallpaper
    pkgs.gnomeExtensions.hue-lights
    pkgs.gnomeExtensions.light-style
    pkgs.gnomeExtensions.night-theme-switcher
    pkgs.gnomeExtensions.pano
    pkgs.gnomeExtensions.picture-of-the-day
    pkgs.gnomeExtensions.pip-on-top
    pkgs.gnomeExtensions.run-or-raise
    pkgs.gnomeExtensions.somafm-internet-radio
    pkgs.gnomeExtensions.unblank
  ];

  dconf.settings = {

    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "caffeine@patapon.info"
        "hue-lights@chlumskyvaclav.gmail.com"
        "just-perfection-desktop@just-perfection"
        "light-style@gnome-shell-extensions.gcampax.github.com"
        "nightthemeswitcher@romainvigier.fr"
        "one-thing@github.com"
        "pano@elhan.io"
        "picture-of-the-day@swsnr.de"
        "pip-on-top@rafostar.github.com"
        "run-or-raise@edvard.cz"
        "unblank@sun.wxg@gmail.com"
        #"ddterm@amezin.github.com"
        #"github.notifications@alexandre.dufournet.gmail.com"
        #"gsconnect@andyholmes.github.io"
        #"mediacontrols@cliffniff.github.com"
      ];
    };

    "org/gnome/shell/extensions/swsnr-picture-of-the-day" = {
      selected-source = "bing";
    };

    "org/gnome/shell/extensions/mediacontrols" = {
      extension-position = "center";
      max-widget-width = 500;
      mouse-actions = [
        "toggle_play"
        "toggle_menu"
        "none"
        "none"
        "none"
        "none"
        "none"
        "none"
      ];
      show-control-icons = false;
      show-seperators = false;
      track-label = [ "track" "-" "artist" ];
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

    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      animation = 2;
      app-menu = false;
      calendar = false;
      clock-menu-position = 2;
      dash = false;
      events-button = false;
      hot-corner = false;
      power-icon = false;
      show-apps-button = true;
      startup-status = 0;
      type-to-search = false;
      world-clock = false;
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

    "org/gnome/shell/extensions/googleearthwallpaper" = { hide = true; };

    "org/gnome/shell/extensions/one-thing" = {
      index-in-status-bar = 1;
      location-in-status-bar = 0;
      show-settings-button-on-popup = false;
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 500;
      keep-search-entry = false;
      open-links-in-browser = false;
      play-audio-on-copy = false;
      send-notification-on-copy = false;
      show-indicator = false;
      window-position = lib.hm.gvariant.mkUint32 (1); # right side of the screen
    };

    "org/gnome/shell/extensions/pano/text-item" = {
      body-bg-color = "rgb(153,193,241)";
    };

    "org/gnome/shell/extensions/unblank" = {
      power = false;
      time = 1800;
    };

    # drop down menu for somafm, vpn and fend
    "com/github/amezin/ddterm" = {
      #custom-font = "Hasklug Nerd Font 13";
      audible-bell = false;
      background-color = "rgb(46,52,54)";
      bold-color-same-as-fg = true;
      bold-is-bright = true;
      command = "custom-command";
      custom-command =
        "zsh -ceil -- 'cd /home/nelson/Documents;/home/nelson/.nix-profile/bin/chatgpt'";
      custom-font = "B612 Mono 13";
      ddterm-toggle-hotkey = [ "<Super>t" ];
      hide-when-focus-lost = true;
      new-tab-button = false;
      notebook-border = false;
      override-window-animation = false;
      panel-icon-type = "none";
      scroll-on-output = true;
      shortcuts-enabled = false;
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
      #/com/github/amezin/ddterm/shortcuts-enabled
      #  true
      #
      #/com/github/amezin/ddterm/shortcut-font-scale-increase
      #  @as []
      #
      #/com/github/amezin/ddterm/shortcut-font-scale-increase
      #  ['<Primary>plus']
      #
      #/com/github/amezin/ddterm/shortcut-font-scale-decrease
      #  ['<Primary>underscore']
    };
  };
}
