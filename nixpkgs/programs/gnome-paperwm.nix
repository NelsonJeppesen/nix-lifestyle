{ config, lib, pkgs, ... }:

{
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
      toggle-application-view   = [ "<Super>space" ];
      toggle-overview           = [];  # Free up <Super>S
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

      custom-keybindings = [
        # custom bindings 1x - terminal
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"

        # custom bindings 2x - chrome based/realted
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom20/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom21/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom22/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom23/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom24/"

        # custom bindings 9x - misc
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom90/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom92/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom93/"
      ];

    };

    # custom binding 1x - terminal
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
      binding = "<Super>backslash";
      command = ".local/bin/focus-wayland-class kitty kitty";
      name    = "kitty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
      binding = "<Shift><Super>backslash";
      command = "kitty --single-instance";
      name    = "kitty (new window)";
    };

    # custom bindings 2x - chrome based shortcuts
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom20" = {
      binding = "<Super>x";
      command = "bash -c \"wmctrl -xa chrome/work; [ \"$?\" == \"1\" ] && google-chrome-stable --user-data-dir=$HOME/.config/chrome/work\"";
      name    = "chrome (work)";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom21" = {
      binding = "<Super>b";
      command = "bash -c \"wmctrl -xa chrome/personal; [ \"$?\" == \"1\" ] && google-chrome-stable --user-data-dir=$HOME/.config/chrome/personal \"";
      name    = "chrome (personal)";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom22" = {
      binding = "<Super>w";
      command = "bash -c \"wmctrl -xa web.whatsapp; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/whatsapp --app=https://web.whatsapp.com \"";
      name    = "whatsapp";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom23" = {
      binding = "<Super>d";
      command = "bash -c \"wmctrl -xa discord.com__app; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/discord --app=https://discord.com/app \"";
      name    = "discord";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom24" = {
      binding = "<Super>y";
      command = "bash -c \"wmctrl -xa www.youtube.com; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/personal --app=https://www.youtube.com \"";
      name    = "youtube";
    };

    # custom bindings 9x - misc
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom90" = {
      binding = "<Super>F3";
      command = "bash -c \"wmctrl -a coolncspot; [ \"$?\" == \"1\" ] && cool-retro-term -T coolncspot --default-settings -e ncspot\"";
      name    = "ncspotify";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91" = {
      binding = "Print";
      command = "flameshot gui";
      name    = "flameshot screenshot";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom92" = {
      binding = "<Super>s";
      #command = "bash -c \"wmctrl -a slack; [ \"$?\" == \"1\" ] && slack\"";
      command = "bash -c \"wmctrl -xa apptentive.slack.com; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/work --app=https://apptentive.slack.com \"";
      name    = "slack";
    };



    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom93" = {
      binding = "<Super>z";
      command = "wmctrl -a 'Zoom Meeting'";
      name    = "focus zoom running zoom meeting";
    };

  };
}
