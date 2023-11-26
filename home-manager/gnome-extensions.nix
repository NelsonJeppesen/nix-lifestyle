{ config, lib, pkgs, ... }:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  home.packages = [
    #pkgs.gnomeExtensions.bluetooth-quick-connect
    #pkgs.gnomeExtensions.blur-my-shell
    #pkgs.gnomeExtensions.ddterm
    #pkgs.gnomeExtensions.github-notifications
    #pkgs.gnomeExtensions.gsconnect
    #pkgs.gnomeExtensions.hue-lights
    #pkgs.gnomeExtensions.just-perfection
    #pkgs.gnomeExtensions.media-controls
    #pkgs.gnomeExtensions.night-theme-switcher
    #pkgs.gnomeExtensions.one-thing
    #pkgs.gnomeExtensions.pano
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.caffeine
    pkgs.gnomeExtensions.google-earth-wallpaper
    pkgs.gnomeExtensions.light-style
    pkgs.gnomeExtensions.pip-on-top
    pkgs.gnomeExtensions.run-or-raise
    pkgs.gnomeExtensions.unblank
  ];

  dconf.settings = {

    "org/gnome/shell" = {
      enabled-extensions = [
        "GoogleEarthWallpaper@neffo.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "caffeine@patapon.info"
        "ddterm@amezin.github.com"
        "just-perfection-desktop@just-perfection"
        "nightthemeswitcher@romainvigier.fr"
        "one-thing@github.com"
        "pano@elhan.io"
        "pip-on-top@rafostar.github.com"
        "run-or-raise@edvard.cz"
        "unblank@sun.wxg@gmail.com"
        #"github.notifications@alexandre.dufournet.gmail.com"
        #"gsconnect@andyholmes.github.io"
        #"hue-lights@chlumskyvaclav.gmail.com"
        #"lightshell@dikasp.gitlab"
        #"mediacontrols@cliffniff.github.com"
      ];
    };

    "org/gnome/shell/extensions/mediacontrols" = {
      extension-position = "center";
      max-widget-width = 500;
      mouse-actions = [ "toggle_play" "toggle_menu" "none" "none" "none" "none" "none" "none" ];
      show-control-icons = false;
      show-seperators = false;
      track-label = [ "track" "-" "artist" ];
    };

    "org/gnome/shell/extensions/appindicator" = {
      icon-brightness = -0.10000000000000001;
      icon-opacity = 255;
      icon-saturation = 0.80000000000000004;
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
      sunset = "kitty @ --to unix:/tmp/kitty set-colors --all /nix/store/3a0j7pdbj8hi0lzfmahxqp37rq3d6swp-kitty-themes-unstable-2023-03-08/share/kitty-themes/themes/rose-pine-moon.conf";
      sunrise = "kitty @ --to unix:/tmp/kitty set-colors --all /nix/store/3a0j7pdbj8hi0lzfmahxqp37rq3d6swp-kitty-themes-unstable-2023-03-08/share/kitty-themes/themes/PencilLight.conf";
    };

    "org/gnome/shell/extensions/nightthemeswitcher/shell-variants" = {
      enabled = true;
      day = "LightShell";
      night = "";
    };

    "org/gnome/shell/extensions/googleearthwallpaper" = {
      hide = true;
    };

    "org/gnome/shell/extensions/one-thing" = {
      index-in-status-bar = 1;
      location-in-status-bar = 0;
      show-settings-button-on-popup = false;
    };

    "org/gnome/shell/extensions/pano" = {
      history-length = 500;
      play-audio-on-copy = false;
      show-indicator = false;
      send-notification-on-copy = false;
    };

    "org/gnome/shell/extensions/pano/text-item" = {
      body-bg-color = "rgb(153,193,241)";
    };

    "org/gnome/shell/extensions/unblank" = {
      power = false;
      time = 1800;
    };

    # drop down menu for somafm, vpn and fend
    #"com/github/amezin/ddterm" = {
    #  audible-bell = false;
    #  background-color = "rgb(25,15,26)";
    #  background-opacity = 0.75;
    #  bold-color-same-as-fg = true;
    #  bold-is-bright = false;
    #  command = "custom-command";
    #  custom-command = "bash -c 'nvim /home/nelson/s/notes/$(date +work-%Y-%q).md'";
    #  custom-font = "Hasklug Nerd Font 13";
    #  ddterm-toggle-hotkey = [ "<Super>t" ];
    #  hide-animation = "ease-in-out-back";
    #  hide-animation-duration = 0.2;
    #  hide-when-focus-lost = false;
    #  new-tab-button = false;
    #  notebook-border = false;
    #  override-window-animation = true;
    #  panel-icon-type = "none";
    #  scroll-on-output = true;
    #  shortcuts-enabled = false;
    #  show-animation = "ease-in-out-back";
    #  show-animation-duration = 0.2;
    #  show-scrollbar = false;
    #  tab-close-buttons = false;
    #  tab-expand = false;
    #  tab-label-ellipsize-mode = "middle";
    #  tab-label-width = 0.1;
    #  tab-policy = "automatic";
    #  tab-position = "top";
    #  tab-switcher-popup = false;
    #  transparent-background = true;
    #  use-system-font = false;
    #  use-theme-colors = false;
    #  window-above = true;
    #  window-maximize = false;
    #  window-monitor = "primary";
    #  window-position = "right";
    #  window-resizable = false;
    #  window-size = 0.29999999999999999;
    #  window-skip-taskbar = false;
    #};
  };
}
