{ config, lib, pkgs, ... }:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ../dotfiles/shortcuts.conf;

  home.packages = [
    pkgs.gnome3.gpaste
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.ddterm
    pkgs.gnomeExtensions.github-notifications
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.run-or-raise
    pkgs.gnomeExtensions.spotify-tray

    #pkgs.gnomeExtensions.somafm-internet-radio
    #pkgs.gnomeExtensions.taskwhisperer
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-extension-version-validation = true;
      disable-user-extensions = false;
      enabled-extensions = [
        "GPaste@gnome-shell-extensions.gnome.org" # gpaste
        "appindicatorsupport@rgcjonas.gmail.com" # appindicator
        "caffeine@patapon.info" # caffeine
        "ddterm@amezin.github.com" # ddterm drop down term
        "github.notifications@alexandre.dufournet.gmail.com" #github-notifications
        "gsconnect@andyholmes.github.io"
        "run-or-raise@edvard.cz" # run-or-raise
        "sp-tray@sp-tray.esenliyim.github.com" # spotify-tray
      ];
    };

    # drop down menu for somafm, vpn and fend
    "com/github/amezin/ddterm" = {
      audible-bell = false;
      background-color = "rgb(0,0,0)";
      background-opacity = 0.7;
      bold-color = "rgb(205,171,143)";
      bold-color-same-as-fg = true;
      custom-font = "Hasklug Nerd Font 13";
      ddterm-toggle-hotkey = [ "<Super>t" ];
      foreground-color = "rgb(153,193,241)";
      hide-when-focus-lost = true;
      new-tab-button = false;
      notebook-border = false;
      panel-icon-type = "toggle-button";
      scroll-on-output = true;
      show-scrollbar = false;
      tab-close-buttons = false;
      tab-expand = false;
      tab-label-width = 0.1;
      tab-policy = "always";
      tab-position = "top";
      tab-switcher-popup = false;
      theme-variant = "dark";
      transparent-background = true;
      use-system-font = false;
      use-theme-colors = false;
      window-maximize = false;
      window-position = "top";
      window-size = 0.4;

      shortcuts-enabled = true;
      shortcut-find = [ "<Primary><Shift>s" ];
      shortcut-find-next = [ ];
      shortcut-find-prev = [ ];
      shortcut-move-tab-next = [ "<Primary>greater" ];
      shortcut-move-tab-prev = [ "<Primary>less" ];
      shortcut-next-tab = [ "<Primary><Shift>Right" ];
      shortcut-page-close = [ "<Primary>BackSpace" ];
      shortcut-prev-tab = [ "<Primary><Shift>Left" ];
      shortcut-background-opacity-dec = [ "<Primary>underscore" ];
      shortcut-background-opacity-inc = [ "<Primary>plus" ];
      shortcut-switch-to-tab-1 = [ ];
      shortcut-switch-to-tab-2 = [ ];
      shortcut-switch-to-tab-3 = [ ];
      shortcut-switch-to-tab-4 = [ ];
      shortcut-switch-to-tab-5 = [ ];
      shortcut-switch-to-tab-6 = [ ];
      shortcut-switch-to-tab-7 = [ ];
      shortcut-switch-to-tab-8 = [ ];
      shortcut-switch-to-tab-9 = [ ];
      shortcut-switch-to-tab-10 = [ ];
      shortcut-toggle-maximize = [ ];
      shortcut-window-hide = [ ];
      shortcut-window-size-dec = [ ];
      shortcut-window-size-inc = [ ];

      palette = [
        "rgb(0x17, 0x14, 0x21)"
        "rgb(0xc0, 0x1c, 0x28)"
        "rgb(0x26, 0xa2, 0x69)"
        "rgb(0xa2, 0x73, 0x4c)"
        "rgb(0x12, 0x48, 0x8b)"
        "rgb(0xa3, 0x47, 0xba)"
        "rgb(0x2a, 0xa1, 0xb3)"
        "rgb(0xd0, 0xcf, 0xcc)"
        "rgb(0x5e, 0x5c, 0x64)"
        "rgb(0xf6, 0x61, 0x51)"
        "rgb(0x33, 0xd1, 0x7a)"
        "rgb(0xe9, 0xad, 0x0c)"
        "rgb(0x2a, 0x7b, 0xde)"
        "rgb(0xc0, 0x61, 0xcb)"
        "rgb(0x33, 0xc7, 0xde)"
        "rgb(0xff, 0xff, 0xff)"
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

    "org/gnome/GPaste" = {
      images-support = true;
      max-history-size = lib.hm.gvariant.mkUint64 2000;
      max-memory-usage = lib.hm.gvariant.mkUint64 100;
      trim-items = true;
    };

    "org/gnome/desktop/interface" = {
      clock-format = "12h";
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      show-battery-percentage = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      show-notifications = false;
      user-enabled = false;
    };
    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source = [ ]; # Free up <Super>space
      switch-input-source-backward = [ ]; # Free up <Super><Shift>space
      toggle-message-tray = [ ]; # Free up <Super>m
      close = [ "<Super>BackSpace" ];
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
    };

    "org/gnome/desktop/interface" = {
      gtk-theme = "Adwaita-dark";
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
