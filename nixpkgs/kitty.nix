{ config, pkgs, ... }:
{

  home.file.".config/kitty/kitty.startup.session".text = ''
    new_tab
    launch
  '';

  programs = {

    kitty = {
      enable = true;

      font = {
        name    = "Hasklug Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "Hasklig"]; };
      };

      keybindings = {
        "kitty_mod+backspace"  = "close_window";
        "kitty_mod+j"          = "next_window";
        "kitty_mod+k"          = "prev_window";
        "kitty_mod+l"          = "next_tab";
        "kitty_mod+h"          = "prev_tab";
        "kitty_mod+right"      = "no-op";
        "kitty_mod+left"       = "no-op";
        "kitty_mod+s"          = "show_scrollback";
      };

      settings = {
        #kitty_mod                  = "Super_L+shift";
        background_opacity          = "1.0";
        copy_on_select              = true;
        enable_audio_bell           = false;
        enabled_layouts             = "fat:bias=55,tall:bias=55,stack";
        font_size                   = "15.0";
        bold_font                   = "Hasklug Medium Nerd Font Complete Mono";
        hide_window_decorations     = true ;
        inactive_text_alpha         = "0.5";
        linux_display_server        = "wayland";
        macos_show_window_title_in  = "none" ;
        scrollback_lines            = "30000";
        #startup_session             = "kitty.startup.session";
        strip_trailing_spaces       = "smart";
        tab_bar_style               = "powerline";
        tab_powerline_style         = "slanted";
        term                        = "xterm-256color";
        update_check_interval       = "0";
        window_border_width         = "0.0pt";
        window_margin_width         = "7";

        # https://github.com/rebelot/kanagawa.nvim/blob/master/extras/kanagawa.conf
        background                  = "#2E2E34";  # modified to make vim and term bg different

        foreground                  = "#DCD7BA";
        selection_background        = "#2D4F67";
        selection_foreground        = "#C8C093";
        url_color                   = "#72A7BC";
        cursor                      = "#C8C093";
        active_tab_background       = "#2D4F67";
        active_tab_foreground       = "#DCD7BA";
        inactive_tab_background     = "#223249";
        inactive_tab_foreground     = "#727169";
        color0                      = "#090618";
        color1                      = "#C34043";
        color2                      = "#76946A";
        color3                      = "#C0A36E";
        color4                      = "#7E9CD8";
        color5                      = "#957FB8";
        color6                      = "#6A9589";
        color7                      = "#C8C093";
        color8                      = "#727169";
        color9                      = "#E82424";
        color10                     = "#98BB6C";
        color11                     = "#E6C384";
        color12                     = "#7FB4CA";
        color13                     = "#938AA9";
        color14                     = "#7AA89F";
        color15                     = "#DCD7BA";
        color16                     = "#FFA066";
        color17                     = "#FF5D62";

        #background            = "#2c2c2c";
        #foreground            = "#cccccc";
        #cursor                = "#cccccc";
        #selection_background  = "#505050";
        #color0                = "#000000";
        #color8                = "#000000";
        #color1                = "#f17779";
        #color9                = "#f17779";
        #color2                = "#99cc99";
        #color10               = "#99cc99";
        #color3                = "#ffcc66";
        #color11               = "#ffcc66";
        #color4                = "#6699cc";
        #color12               = "#6699cc";
        #color5                = "#cc99cc";
        #color13               = "#cc99cc";
        #color6                = "#66cccc";
        #color14               = "#66cccc";
        #color7                = "#fffefe";
        #color15               = "#fffefe";
        #selection_foreground  = "#2c2c2c";
      };
    };
  };
}
