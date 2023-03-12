{ config, lib, pkgs, ... }:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ../dotfiles/shortcuts.conf;

  home.packages = [
    #pkgs.gnome3.gpaste
    #pkgs.gnomeExtensions.adjust-display-brightness
    #pkgs.gnomeExtensions.bing-wallpaper-changer
    #pkgs.gnomeExtensions.brightness-control-using-ddcutil
    #pkgs.gnomeExtensions.brightness-panel-menu-indicator
    #pkgs.gnomeExtensions.display-ddc-brightness-volume
    #pkgs.gnomeExtensions.github-notifications
    #pkgs.gnomeExtensions.gsconnect
    #pkgs.gnomeExtensions.hue-lights
    #pkgs.gnomeExtensions.nasa-apod
    #pkgs.gnomeExtensions.pingindic
    #pkgs.gnomeExtensions.quick-settings-tweaker
    #pkgs.gnomeExtensions.random-wallpaper
    #pkgs.gnomeExtensions.shu-zhi
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.bluetooth-quick-connect
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.ddterm
    pkgs.gnomeExtensions.google-earth-wallpaper
    pkgs.gnomeExtensions.pano
    pkgs.gnomeExtensions.pip-on-top
    pkgs.gnomeExtensions.run-or-raise
    pkgs.gnomeExtensions.spotify-tray
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
      enabled-extensions = [
        "GoogleEarthWallpaper@neffo.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "caffeine@patapon.info"
        "ddterm@amezin.github.com"
        "pano@elhan.io"
        "pip-on-top@rafostar.github.com"
        "run-or-raise@edvard.cz"
        "sp-tray@sp-tray.esenliyim.github.com"
        #"BingWallpaper@ineffable-gmail.com"
        #"GPaste@gnome-shell-extensions.gnome.org"
        #"github.notifications@alexandre.dufournet.gmail.com"
        #"gsconnect@andyholmes.github.io"
        #"hue-lights@chlumskyvaclav.gmail.com"
        #"nasa_apod@elinvention.ovh"
        #"shuzhi@tuberry"
      ];
    };

    # drop down menu for somafm, vpn and fend
    "com/github/amezin/ddterm" = {
      audible-bell = false;
      background-opacity = 0.7;
      background-color = "rgb(25,15,26)";
      bold-color-same-as-fg = true;
      bold-is-bright = false;
      custom-font = "Hasklug Nerd Font 13";
      ddterm-toggle-hotkey = [ "<Super>t" ];
      hide-animation = "ease-in-out-back";
      hide-animation-duration = 0.2;
      hide-when-focus-lost = true;
      new-tab-button = false;
      notebook-border = false;
      override-window-animation = true;
      panel-icon-type = "none";
      scroll-on-output = true;
      shortcut-background-opacity-dec = [ "<Primary>underscore" ];
      shortcut-background-opacity-inc = [ "<Primary>plus" ];
      shortcut-find = [ "<Primary><Shift>s" ];
      shortcut-find-next = [ ];
      shortcut-find-prev = [ ];
      shortcut-move-tab-next = [ "<Primary>greater" ];
      shortcut-move-tab-prev = [ "<Primary>less" ];
      shortcut-next-tab = [ "<Primary><Shift>Right" ];
      shortcut-page-close = [ "<Primary>BackSpace" ];
      shortcut-prev-tab = [ "<Primary><Shift>Left" ];
      shortcut-switch-to-tab-1 = [ ];
      shortcut-switch-to-tab-10 = [ ];
      shortcut-switch-to-tab-2 = [ ];
      shortcut-switch-to-tab-3 = [ ];
      shortcut-switch-to-tab-4 = [ ];
      shortcut-switch-to-tab-5 = [ ];
      shortcut-switch-to-tab-6 = [ ];
      shortcut-switch-to-tab-7 = [ ];
      shortcut-switch-to-tab-8 = [ ];
      shortcut-switch-to-tab-9 = [ ];
      shortcut-toggle-maximize = [ ];
      shortcut-window-hide = [ ];
      shortcut-window-size-dec = [ ];
      shortcut-window-size-inc = [ ];
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
      transparent-background = true;
      use-system-font = false;
      use-theme-colors = false;
      window-above = true;
      window-maximize = false;
      window-monitor = "primary";
      window-position = "right";
      window-resizable = false;
      window-size = 0.29999999999999999;
      window-skip-taskbar = false;

      palette = [
        "rgb(23,20,33)"
        "rgb(233,40,136)"
        "rgb(78,201,176)"
        "rgb(206,145,120)"
        "rgb(87,155,213)"
        "rgb(113,72,150)"
        "rgb(42,161,179)"
        "rgb(234,234,234)"
        "rgb(121,121,121)"
        "rgb(235,42,136)"
        "rgb(26,214,156)"
        "rgb(233,173,149)"
        "rgb(156,220,254)"
        "rgb(151,94,171)"
        "rgb(43,196,226)"
        "rgb(234,234,234)"
      ];

    };

    "org/gnome/shell/extensions/github-notifications" = {
      handle = "NelsonJeppesen";
      hide-widget = true;
      refresh-interval = 61;
    };

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "caps:super" # map capslock to windows/mac key
        "numpad:mac" # always enable numlock
        "f:XF86AudioRaiseVolume"
      ];
    };

    "org/gnome/shell/extensions/appindicator" = {
      tray-pos = "center";
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 500;
      play-audio-on-copy = false;
      show-indicator = false;
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/shell/keybindings" = {
      toggle-message-tray = [ "<Super>v" ];
      toggle-overview = [ ]; # free super-s
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position = -1;
      indicator-position-index = -1;
      screen-blank = "always";
      show-indicator = "only-active";
      show-notifications = false;
      toggle-shortcut = [ "<Super>c" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ ]; # Free up <Super>space
      switch-input-source-backward = [ ]; # Free up <Super><Shift>space
      toggle-message-tray = [ "<Super>v" ]; # Free up <Super>m
      close = [ "<Super>BackSpace" ];
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
    };

    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      next = [ "<Super>bracketright" ];
      play = [ "<Super>backslash" ];
      previous = [ "<Super>bracketleft" ];
      search = [ "<Super>space" ];
      screenshot = [ ]; # free up for flameshot
      volume-down = [ "<Shift><Super>braceleft" ];
      volume-up = [ "<Shift><Super>braceright" ];

      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "Print";
      command = "${pkgs.flameshot}/bin/flameshot gui";
      name = "flameshot screenshot";
    };

    "org/gnome/mutter" = {
      # active screen edge. Drag windows to edge of screen to resize
      edge-tiling = true;
    };
  };
}
