{ pkgs, ... }:
{
  home.file.".config/run-or-raise/shortcuts.conf".source = ./dotfiles/shortcuts.conf;

  programs.gnome-shell = {
    enable = true;
    extensions = [
      { package = pkgs.gnomeExtensions.appindicator; }
      { package = pkgs.gnomeExtensions.bitcoin-markets; }
      { package = pkgs.gnomeExtensions.caffeine; }
      { package = pkgs.gnomeExtensions.clipboard-indicator; }
      { package = pkgs.gnomeExtensions.just-perfection; }
      { package = pkgs.gnomeExtensions.picture-of-the-day; }
      { package = pkgs.gnomeExtensions.run-or-raise; }
      { package = pkgs.gnomeExtensions.todotxt; }

      # "Play lofi music on your Gnome desktop with just a click!"
      #   https://github.com/eucaue/gnome-shell-extension-quick-lofi
      { package = pkgs.gnomeExtensions.quick-lofi; }
    ];
  };

  dconf.settings = {

    "org/gnome/shell/extensions/TodoTxt" = {
      donetxt-location = "/home/nelson/source/personal/notes/done.txt";
      todotxt-location = "/home/nelson/source/personal/notes/todo.txt";

      add-creation-date = true;
      auto-archive = true;
      confirm-delete = false;
      keep-open-after-new = true;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = false;
      dash = false;
      search = true;
      startup-status = 0; # disable the overview popup thing
      theme = false;
      window-maximized-on-create = true;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      cache-size = 10;
      clear-history = [ ];
      disable-down-arrow = true;
      display-mode = 1;
      history-size = 200;
      move-item-first = true;
      next-entry = [ "<Shift><Control>p" ];
      paste-button = false;
      prev-entry = [ "<Shift><Control>o" ];
      private-mode-binding = [ ];
      strip-text = true;
      toggle-menu = [ "<Shift><Control>i" ];
      topbar-preview-size = 9;
    };

    "org/gnome/shell/extensions/quick-lofi" = {
      volume = 75;
      set-popup-max-height = false;

      # SomaFM Radios (all channels as of 2025-09-21)
      radios = [
        "SomaFM Beat Blender - https://api.somafm.com/beatblender130.pls"
        "SomaFM Black Rock FM - https://api.somafm.com/brfm130.pls"
        "SomaFM Boot Liquor - https://api.somafm.com/bootliquor130.pls"
        "SomaFM Bossa Beyond - https://api.somafm.com/bossa130.pls"
        "SomaFM Chillits Radio - https://api.somafm.com/chillits130.pls"
        "SomaFM cliqhop idm - https://api.somafm.com/cliqhop130.pls"
        "SomaFM Covers - https://api.somafm.com/covers130.pls"
        "SomaFM Deep Space One - https://api.somafm.com/deepspaceone130.pls"
        "SomaFM DEF CON Radio - https://api.somafm.com/defcon130.pls"
        "SomaFM Digitalis - https://api.somafm.com/digitalis130.pls"
        "SomaFM Doomed - https://api.somafm.com/doomed130.pls"
        "SomaFM Drone Zone - https://api.somafm.com/dronezone130.pls"
        "SomaFM Dub Step Beyond - https://api.somafm.com/dubstep130.pls"
        "SomaFM Fluid - https://api.somafm.com/fluid130.pls"
        "SomaFM Folk Forward - https://api.somafm.com/folkfwd130.pls"
        "SomaFM Groove Salad - https://api.somafm.com/groovesalad130.pls"
        "SomaFM Groove Salad Classic - https://api.somafm.com/gsclassic130.pls"
        "SomaFM Heavyweight Reggae - https://api.somafm.com/reggae130.pls"
        "SomaFM Illinois Street Lounge - https://api.somafm.com/illstreet130.pls"
        "SomaFM Indie Pop Rocks! - https://api.somafm.com/indiepop130.pls"
        "SomaFM Left Coast 70s - https://api.somafm.com/seventies130.pls"
        "SomaFM Live - https://api.somafm.com/live130.pls"
        "SomaFM Lush - https://api.somafm.com/lush130.pls"
        "SomaFM Metal Detector - https://api.somafm.com/metal130.pls"
        "SomaFM Mission Control - https://api.somafm.com/missioncontrol130.pls"
        "SomaFM n5MD Radio - https://api.somafm.com/n5md130.pls"
        "SomaFM PopTron - https://api.somafm.com/poptron130.pls"
        "SomaFM Secret Agent - https://api.somafm.com/secretagent130.pls"
        "SomaFM Seven Inch Soul - https://api.somafm.com/7soul130.pls"
        "SomaFM SF 10-33 - https://api.somafm.com/sf1033130.pls"
        "SomaFM SF in SF - https://api.somafm.com/sfinsf130.pls"
        "SomaFM SF Police Scanner - https://api.somafm.com/scanner130.pls"
        "SomaFM Sonic Universe - https://api.somafm.com/sonicuniverse130.pls"
        "SomaFM Space Station Soma - https://api.somafm.com/spacestation130.pls"
        "SomaFM Specials - https://api.somafm.com/specials130.pls"
        "SomaFM Suburbs of Goa - https://api.somafm.com/suburbsofgoa130.pls"
        "SomaFM Synphaera Radio - https://api.somafm.com/synphaera130.pls"
        "SomaFM The Dark Zone - https://api.somafm.com/darkzone130.pls"
        "SomaFM The In-Sound - https://api.somafm.com/insound130.pls"
        "SomaFM Tiki Time - https://api.somafm.com/tikitime130.pls"
        "SomaFM Vaporwaves - https://api.somafm.com/vaporwaves130.pls"
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
      indicator-position = 17;
      indicator-position-index = 3;
      screen-blank = "never";
      show-indicator = "only-active";
      show-notifications = false;
      toggle-shortcut = [ "<Super>c" ];
    };
  };
}
