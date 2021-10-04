{ config, pkgs, ... }:
{

  home.file.".config/kitty/kitty.startup.session".text = ''
    new_tab
    #cd ~/s
    launch
  '';

  programs = {

    kitty = {
      enable = true;

      font = {
        package = pkgs.nerdfonts;
        #name = "VictorMono Nerd Font Mono";
        name = "Lekton Nerd Font";
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
        background_image_linear     = "yes";
        #background_image            = "~/s/nix-lifestyle/nixpkgs/dotfiles/kitty-background.png";
        background_image_layout     = "scaled";
        background_opacity          = "1.0";
        background_tint             = "0.75";
        copy_on_select              = true;
        enable_audio_bell           = false;
        enabled_layouts             = "fat:bias=65,tall:bias=60,stack";
        font_size                   = "16.0";
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
