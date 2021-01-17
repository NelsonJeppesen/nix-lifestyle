{ config, pkgs, ... }:
{
  programs = {

    kitty = {
      enable = true;

      keybindings = {
        "cmd+0" = "goto_tab 10";
        "cmd+1" = "goto_tab 1";
        "cmd+2" = "goto_tab 2";
        "cmd+3" = "goto_tab 3";
        "cmd+4" = "goto_tab 4";
        "cmd+5" = "goto_tab 5";
        "cmd+6" = "goto_tab 6";
        "cmd+7" = "goto_tab 7";
        "cmd+8" = "goto_tab 8";
        "cmd+9" = "goto_tab 9";
        "cmd+w" = "close_window";
        "ctrl+shift+enter" =  "launch --cwd=current";
      };

      settings = {
        copy_on_select              = true;
        background_opacity          = "0.96";
        enable_audio_bell           = false;
        font_size                   = "12.0";
        update_check_interval       = "24";
        hide_window_decorations     = true ;
        macos_show_window_title_in  = "none" ;
        scrollback_lines            = "10000";
        strip_trailing_spaces       = "smart";
        #tab_bar_min_tabs            = "1";
        tab_bar_style               = "powerline";
        tab_title_template          = " {index} ";

        background            = "#181c27";
        foreground            = "#ada37a";
        cursor                = "#91805a";
        selection_background  = "#172539";
        color0                = "#181818";
        color8                = "#555555";
        color1                = "#800009";
        color9                = "#ab3834";
        color2                = "#48513b";
        color10               = "#a6a65d";
        color3                = "#cc8a3e";
        color11               = "#dcde7b";
        color4                = "#566d8c";
        color12               = "#2f97c6";
        color5                = "#724c7c";
        color13               = "#d33060";
        color6                = "#5b4f4a";
        color14               = "#f3dab1";
        color7                = "#ada37e";
        color15               = "#f3f3f3";
        selection_foreground  = "#181c27";
      };
    };
  };
}
