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
            #kitty -c ~/.config/kitty/kitty.conf -c $THEME_PATH/Belafonte_Day.conf
            kitty -c ~/.config/kitty/kitty.conf -c $THEME_PATH/Solarized_Light.conf
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

      keybindings = {
        "kitty_mod+]" = "next_layout";

        # new windows inside existing tab
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

        # Set fonts; disable bold
        bold_font = "Source Code Pro Medium";
        bold_italic_font = "Source Code Pro Medium";
        font = "Source Code Pro Medium";
        font_size = "14.0";

        window_border_width = "1.0pt";
        window_margin_width = "7";
        active_border_color = "#74B3CE";
        inactive_border_color = "#aaaaaa";
        bell_border_color = "#ff5a00";

        # Don't use patched fonts
        # have kitty bring in Symbols from Nerd Font
        # https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
        symbol_map = "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 Symbols Nerd Font Mono";

        allow_remote_control = "password";
        copy_on_select = true;
        enable_audio_bell = false;
        hide_window_decorations = true;
        inactive_text_alpha = "0.65";
        linux_display_server = "wayland";
        remote_control_password = ''"" *-colors'';
        scrollback_lines = "30000";
        shell_integration = "no-cursor";
        strip_trailing_spaces = "smart";
        tab_bar_min_tabs = 1;
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        term = "xterm-256color";
        update_check_interval = "0";

        enabled_layouts = "vertical,horizontal,grid,stack";
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
