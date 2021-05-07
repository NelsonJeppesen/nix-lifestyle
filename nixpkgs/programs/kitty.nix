{ config, pkgs, ... }:
{

  home = {
    file.".config/kitty/kitty.startup.session".source = ../dotfiles/kitty.startup.session;
  };

  programs = {

    kitty = {
      enable = true;

      font = {
        package = pkgs.fira-code;
        name = "Fira Code";
      };

      keybindings = {
        "ctrl+shift+backspace"  = "close_window";
        "ctrl+shift+down"       = "next_window";
        "ctrl+shift+up"         = "prev_window";
      };

      settings = {
        #kitty_mod                  = "Super_L+shift";
        copy_on_select              = true;
        enable_audio_bell           = false;
        font_size                   = "16.0";
        hide_window_decorations     = true ;
        linux_display_server        = "x11";
        macos_show_window_title_in  = "none" ;
        scrollback_lines            = "30000";
        startup_session             = "kitty.startup.session";
        strip_trailing_spaces       = "smart";
        tab_bar_style               = "powerline";
        term                        = "xterm-256color";
        update_check_interval       = "0";

        background            = "#2c2c2c";
        foreground            = "#cccccc";
        cursor                = "#cccccc";
        selection_background  = "#505050";
        color0                = "#000000";
        color8                = "#000000";
        color1                = "#f17779";
        color9                = "#f17779";
        color2                = "#99cc99";
        color10               = "#99cc99";
        color3                = "#ffcc66";
        color11               = "#ffcc66";
        color4                = "#6699cc";
        color12               = "#6699cc";
        color5                = "#cc99cc";
        color13               = "#cc99cc";
        color6                = "#66cccc";
        color14               = "#66cccc";
        color7                = "#fffefe";
        color15               = "#fffefe";
        selection_foreground  = "#2c2c2c";
      };
    };
  };
}
