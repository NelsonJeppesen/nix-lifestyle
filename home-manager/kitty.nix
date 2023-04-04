{ config, pkgs, ... }:
{
  home = {
    file = {
      ".config/kitty/kitty.startup.session".text = ''
        new_tab
        launch
      '';

      "/home/nelson/kitty-colorscheme" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          # set color scheme dending if Gnome is set to dark or not

          THEME_PATH="${pkgs.kitty-themes}/share/kitty-themes/themes"
          GNOME_THEME="$(dconf read /org/gnome/desktop/interface/color-scheme | tr -d "'")"

          if [[ "$GNOME_THEME" == "default" ]]; then
            kitty -c ~/.config/kitty/kitty.conf -c $THEME_PATH/rose-pine-dawn.conf
          else
            kitty -c ~/.config/kitty/kitty.conf -c $THEME_PATH/rose-pine-moon.conf
          fi
        '';
      };
    };
  };

  programs = {
    kitty = {
      enable = true;

      font = {
        package = pkgs.nerdfonts;
        name = "SauceCodePro Nerd Font Mono";
      };

      keybindings = {
        "kitty_mod+]" = "next_layout";

        # new windows inside existing tab
        "ctrl+alt+up" = "move_window_backward";
        "ctrl+alt+down" = "move_window_forward";
        "kitty_mod+backspace" = "close_window";
        "kitty_mod+enter" = "launch --cwd=current";
        "kitty_mod+up" = "prev_window";
        "kitty_mod+down" = "next_window";

        # more tabs
        "kitty_mod+left" = "prev_tab";
        "kitty_mod+right" = "next_tab";
        "kitty_mod+n" = "new_tab_with_cwd";

        # search
        "kitty_mod+s" = "show_scrollback";
      };

      settings = {
        copy_on_select = true;
        enable_audio_bell = false;
        font_size = "14.0";
        hide_window_decorations = true;
        inactive_text_alpha = "0.65";
        linux_display_server = "wayland";
        scrollback_lines = "30000";
        strip_trailing_spaces = "smart";
        tab_bar_min_tabs = 1;
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        term = "xterm-256color";
        update_check_interval = "0";
        window_border_width = "0.0pt";
        window_margin_width = "7";

        enabled_layouts = "vertical,horizontal,grid";
        # Fat -- One (or optionally more) windows are shown full width on the top, the rest of the windows are shown side-by-side on the bottom
        # Grid -- All windows are shown in a grid
        # Horizontal -- All windows are shown side-by-side
        # Splits -- Windows arranged in arbitrary patterns created using horizontal and vertical splits
        # Stack -- Only a single maximized window is shown at a time
        # Tall -- One (or optionally more) windows are shown full height on the left, the rest of the windows are shown one below the other on the right
        # Vertical -- All windows are shown one below the other
      };
    };
  };
}
