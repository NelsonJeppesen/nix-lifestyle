{ config, lib, pkgs, ... }:

{
  home.packages = [
    pkgs.flameshot                            # Fancy screenshot tool
    pkgs.gnome3.gpaste
    pkgs.gnomeExtensions.appindicator         # slack notifications
    pkgs.gnomeExtensions.caffeine             # disable sleep on demand
    pkgs.gnomeExtensions.disable-workspace-switch-animation-for-gnome-40
    pkgs.gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.paperwm              # The best tiling window manager
    pkgs.gnomeExtensions.burn-my-windows
    pkgs.gnomeExtensions.run-or-raise
    pkgs.wmctrl                               # Used to "focus or launch" apps
  ];

  home.file.".config/run-or-raise/shortcuts.conf".source = dotfiles/shortcuts.conf;

  dconf.settings = {

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
        "appindicatorsupport@rgcjonas.gmail.com"  # show notifications e.g. slack
        "caffeine@patapon.info"                   # top bar icon to prevent sleep
        "GPaste@gnome-shell-extensions.gnome.org" # clipboard manager with img support
        "gsconnect@andyholmes.github.io"          # connect to my phone
        "paperwm@hedning:matrix.org"              # paperwm - best scrolling WM there is
        "instantworkspaceswitcher@amalantony.net" # fix some UI glitches gnome40+paperwm
        "run-or-raise@edvard.cz"
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

    "org/gnome/shell/extensions/paperwm/keybindings" = {
      switch-left             = ["<Super>h"];
      switch-right            = ["<Super>l"];
    };

    "org/gnome" = {
      toggle-overview         = [];  # Free up <Super>S
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source           = [];  # Free up <Super>space
      switch-input-source-backward  = [];  # Free up <Super><Shift>space
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
