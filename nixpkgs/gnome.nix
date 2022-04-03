{ config, lib, pkgs, ... }:

{
  home.packages = [
    #pkgs.gnomeExtensions.bluetooth-battery
    #pkgs.gnomeExtensions.burn-my-windows
    #pkgs.gnomeExtensions.disable-workspace-switch-animation-for-gnome-40
    #pkgs.gnomeExtensions.gsconnect
    pkgs.flameshot                            # Fancy screenshot tool
    pkgs.gnome3.gpaste
    pkgs.gnomeExtensions.appindicator         # slack notifications
    pkgs.gnomeExtensions.caffeine             # disable sleep on demand
    pkgs.gnomeExtensions.material-shell
    pkgs.gnomeExtensions.run-or-raise
    pkgs.wmctrl                               # Used to "focus or launch" apps
  ];

  home.file.".config/run-or-raise/shortcuts.conf".source = dotfiles/shortcuts.conf;

  dconf.settings = {

    "org/gnome/shell/extensions/materialshell/binding" = {
      app-launcher                = ["<Super>space"];
      cycle-tiling-layout         = [];
      focus-monitor-down          = [];
      focus-monitor-left          = [];
      focus-monitor-right         = [];
      focus-monitor-up            = [];
      kill-focused-window         = ["<Super>BackSpace"];
      last-workspace              = [];
      move-window-bottom          = ["<Control><Super>Down"];
      move-window-left            = ["<Control><Super>Left"];
      move-window-monitor-down    = [];
      move-window-monitor-left    = [];
      move-window-monitor-right   = [];
      move-window-monitor-up      = [];
      move-window-right           = ["<Control><Super>Right"];
      move-window-top             = ["<Control><Super>Up"];
      next-window                 = ["<Super>Right"];
      next-workspace              = ["<Super>Down"];
      previous-window             = ["<Super>Left"];
      previous-workspace          = ["<Super>Up"];
      resize-window-down          = [];
      resize-window-left          = [];
      resize-window-right         = [];
      resize-window-up            = [];
      reverse-cycle-tiling-layout = [];
    };


    "org/gnome/shell/extensions/materialshell/layouts" = {
      screen-gap  = 0;
    };

    "org/gnome/shell/extensions/materialshell/theme" = {
      clock-app-launcher      = false;
      clock-horizontal        = false;
      panel-icon-color        = false;
      panel-icon-style        = "application";
      panel-opacity           = 0;
      panel-size              = 35;
      primary-color           = "#1a5fb4";
      surface-opacity         = 99;
      taskbar-item-style      = "full";
      vertical-panel-position = "left";
    };

    "org/gnome/shell/extensions/materialshell/tweaks" = {
      cycle-through-windows     =true;
      cycle-through-workspaces  =true;
    };

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "caps:super"  # map capslock to windows/mac key
        "numpad:mac"  # always enable numlock
        "f:XF86AudioRaiseVolume"
      ];
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "GPaste@gnome-shell-extensions.gnome.org" # clipboard manager with img support
        "appindicatorsupport@rgcjonas.gmail.com"  # show notifications e.g. slack
        "caffeine@patapon.info"                   # top bar icon to prevent sleep
        "material-shell@papyelgringo"
        "run-or-raise@edvard.cz"
        #"gsconnect@andyholmes.github.io"          # connect to my phone
        #"instantworkspaceswitcher@amalantony.net" # fix some UI glitches gnome40+paperwm
        #"paperwm@hedning:matrix.org"              # paperwm - best scrolling WM there is
      ];
    };

    "org/gnome/GPaste" = {
      "images-support"    = true;
      "max-history-size"  = lib.hm.gvariant.mkUint64 2000;
      "max-memory-usage"  = lib.hm.gvariant.mkUint64 100;
      "trim-items"        = true;
    };

    "org/gnome/desktop/interface" = {
      clock-format  = "12h";
    };

    "org/gnome/shell/extensions/caffeine" = {
      show-notifications      = false;
      user-enabled            = false;
    };

    "org/gnome/shell/extensions/paperwm" = {
      horizontal-margin       = 0;
      vertical-margin         = 0;
      vertical-margin-bottom  = 0;
      window-gap              = 0;
      #cycle-width-steps       = [0.38195 0.6 0.8];
    };

    "org/gnome/shell/keybindings" = {
      # free up keys used by material-shell
      switch-to-application-1 = [];
      switch-to-application-2 = [];
      switch-to-application-3 = [];
      switch-to-application-4 = [];
      switch-to-application-5 = [];
      switch-to-application-6 = [];
      switch-to-application-7 = [];
      switch-to-application-8 = [];
      switch-to-application-9 = [];
      toggle-application-view = [];
      toggle-message-tray     = [];
      toggle-overview         = [];
    };

    "org/gnome/desktop/wm/keybindings" = {
      minimize                      = [];  # Free up <Super>h
      switch-input-source           = [];  # Free up <Super>space
      switch-input-source-backward  = [];  # Free up <Super><Shift>space
      toggle-message-tray           = [];  # Free up <Super>m
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
    };

    "org/gnome/desktop/interface" = {
      gtk-theme   = "Adwaita-dark";
    };

    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {

      # Unset default screenshot key, so I can rebind to flameshot
      screenshot =  [];

      next        = ["<Super>bracketright"];
      previous    = ["<Super>bracketleft"];
      volume-down = ["<Shift><Super>braceleft"];
      volume-up   = ["<Shift><Super>braceright"];

      search      = [ "<Super>space" ];

      custom-keybindings = [
        # custom bindings 1x - terminal
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"

        # custom bindings 9x - misc
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom90/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom93/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
      binding = "<Shift><Super>backslash";
      command = "kitty --single-instance";
      name    = "kitty (new window)";
    };

    # custom bindings 9x - misc
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom90" = {
      binding = "<Super><Shift>s";
      command = "bash -c \"wmctrl -a spotify; [ \"$?\" == \"1\" ] && spotify\"";
      name    = "ncspotify";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91" = {
      binding = "Print";
      command = "flameshot gui";
      name    = "flameshot screenshot";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom93" = {
      binding = "<Super>z";
      command = "wmctrl -a 'Zoom Meeting'";
      name    = "focus zoom running zoom meeting";
    };
  };
}
