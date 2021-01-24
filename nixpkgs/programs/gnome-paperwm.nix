{ config, pkgs, ... }:

{
  dconf.settings = {
    "org/gnome/shell" = {
      #disabled-extensions = [];
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "paperwm@hedning:matrix.org"
      ];
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
      cycle-width-steps       = [0.38195 0.6 0.8];
    };

    "org/gnome/shell/keybindings" = {
      toggle-application-view   = [ "<Super>space" ];
      toggle-overview           = [];  # Free up <Super>S
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-input-source           = [];  # Free up <Super>space
      switch-input-source-backward  = [];  # Free up <Super><Shift>space
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
    };

    "org/gnome/mutter" = {
      overlay-key = "Super_R";
    };

    "org/gnome/desktop/interface" = {
      gtk-theme   = "Adwaita-dark";
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:super" ];
    };

    # Focus apps if running else launch
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>backslash";
      command = "bash -c \"wmctrl -xa kitty ; [ \"$?\" == \"1\" ] && kitty\"";
      name    = "kitty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
      binding = "<Shift><Super>backslash";
      command = "kitty";
      name    = "kitty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>s";
      command = "bash -c \"wmctrl -a slack; [ \"$?\" == \"1\" ] && slack\"";
      name    = "slack";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>x";
      command = "bash -c \"wmctrl -xa chrome/work; [ \"$?\" == \"1\" ] && google-chrome-stable --user-data-dir=$HOME/.config/chrome/work\"";

      name    = "google-chrome-work";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Super>b";
      command = "bash -c \"wmctrl -xa chrome/personal; [ \"$?\" == \"1\" ] && google-chrome-stable --user-data-dir=$HOME/.config/chrome/personal \"";
      name    = "google-chrome-personal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13" = {
      binding = "<shift><Super>b";
      command = "bash -c \"google-chrome-stable --user-data-dir=$HOME/.config/chrome/personal\"";
      name    = "google-chrome-personal";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Super>F3";
      command = "bash -c \"wmctrl -xa spotify; [ \"$?\" == \"1\" ] && spotify\"";
      name    = "spotify";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Super>w";
      command = "bash -c \"wmctrl -xa web.whatsapp; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/whatsapp --app=https://web.whatsapp.com \"";
      name    = "whatsapp";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      binding = "<Super>d";
      command = "bash -c \"wmctrl -xa discord.com__app; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/discord --app=https://discord.com/app \"";
      name    = "google-chrome-whatsapp";
    };


    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      binding = "<Super>y";
      command = "bash -c \"wmctrl -xa www.youtube.com; [ \"$?\" == \"1\" ] && google-chrome-stable -user-data-dir=$HOME/.config/chrome/personal --app=https://www.youtube.com \"";
      name    = "youtube";
    };


    # map the mappings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"

        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13/"
      ];
    };
  };
}

