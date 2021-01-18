{ config, pkgs, ... }:
{
  programs = {

    kitty = {
      enable = true;

      keybindings = {
        #"cmd+0" = "goto_tab 10";
        #"cmd+1" = "goto_tab 1";
        #"cmd+2" = "goto_tab 2";
        #"cmd+3" = "goto_tab 3";
        #"cmd+4" = "goto_tab 4";
        #"cmd+5" = "goto_tab 5";
        #"cmd+6" = "goto_tab 6";
        #"cmd+7" = "goto_tab 7";
        #"cmd+8" = "goto_tab 8";
        #"cmd+9" = "goto_tab 9";
        #"cmd+w" = "close_window";
        #"ctrl+shift+enter" =  "launch --cwd=current";
      };

      settings = {
        copy_on_select              = true;
        enable_audio_bell           = false;
        font_size                   = "12.0";
        hide_window_decorations     = true ;
        macos_show_window_title_in  = "none" ;
        scrollback_lines            = "10000";
        strip_trailing_spaces       = "smart";
        tab_bar_style               = "powerline";
        tab_title_template          = " {index} ";
        update_check_interval       = "0";
        term                        = "xterm-256color";

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
        selection_foreground = "#2c2c2c";
      };
    };
  };
}
