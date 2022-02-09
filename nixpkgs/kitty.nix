{ config, pkgs, ... }:
{

  home.file.".config/kitty/kitty.startup.session".text = ''
    new_tab
    launch
  '';

  programs = {

    kitty = {
      enable = true;
      theme  = "Galaxy";

      font = {
        name    = "Hasklug Nerd Font Mono";
        package = pkgs.nerdfonts.override {fonts = ["Hasklig"];};
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
        background_opacity          = "1.0";
        bold_font                   = "Hasklug Medium Nerd Font Complete Mono";
        copy_on_select              = true;
        enable_audio_bell           = false;
        enabled_layouts             = "fat:bias=55,tall:bias=55,stack";
        font_size                   = "15.0";
        hide_window_decorations     = true ;
        inactive_text_alpha         = "0.5";
        macos_show_window_title_in  = "none" ;
        scrollback_lines            = "30000";
        strip_trailing_spaces       = "smart";
        tab_bar_style               = "powerline";
        tab_powerline_style         = "slanted";
        #term                        = "xterm-256color";
        update_check_interval       = "0";
        window_border_width         = "0.0pt";
        window_margin_width         = "7";
      };
    };
  };
}
