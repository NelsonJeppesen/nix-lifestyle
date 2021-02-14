{ config, pkgs, ... }:

{
  dconf.settings = {

    # Use capslock as super key
    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "caps:super" ];
    };

    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"  # show notifications e.g. slack
        "caffeine@patapon.info"                   # top bar icon to prevent sleep
        "clipboard-indicator@tudmotu.com"         # clipboard manager
        "paperwm@hedning:matrix.org"              # paperwm - best scrolling WM there is
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
      ];

    };

    # custom binding 1x - terminal
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
      binding = "<Super>backslash";
      command = "bash -c \"wmctrl -xa kitty ; [ \"$?\" == \"1\" ] && kitty\"";
      name    = "kitty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
      binding = "<Shift><Super>backslash";
      command = "kitty";
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
      command = "bash -c \"wmctrl -xa spotify; [ \"$?\" == \"1\" ] && spotify\"";
      name    = "spotify";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom91" = {
      binding = "Print";
      command = "flameshot gui";
      name    = "flameshot screenshot";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom92" = {
      binding = "<Super>s";
      command = "bash -c \"wmctrl -a slack; [ \"$?\" == \"1\" ] && slack\"";
      name    = "slack";
    };
  };
}
