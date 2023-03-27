{ config, pkgs, ... }:
{

  home.file.".config/kitty/kitty.startup.session".text = ''
    new_tab
    launch
  '';

  programs = {

    kitty = {
      #theme  = "Seafoam Pastel";
      #theme  = "Spacedust";
      #theme = "Belafonte Day";
      #theme = "Dark One Nuanced";
      #theme = "Dark Pride";
      #theme = "Galaxy";
      #theme = "Pencil Light";
      #theme = "Rosé Pine Dawn";
      #theme = "duckbones";
      #theme = "neobones_light";
      enable = true;
      #theme = "Forest Night";
      #theme = "Wizzy Bright";
      #theme = "shadotheme";
      #theme = "Sea Shells";
      theme = "Ic Orange Ppl";


      font = {
        name = "Hasklug Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "Hasklig" ]; };
      };

      keybindings = {
        "kitty_mod+]" = "next_layout";
        "kitty_mod+backspace" = "close_window";
        "kitty_mod+down" = "next_window";
        "kitty_mod+left" = "prev_tab";
        "kitty_mod+n" = "new_tab_with_cwd";
        "kitty_mod+right" = "next_tab";
        "kitty_mod+s" = "show_scrollback";
        "kitty_mod+up" = "prev_window";
        "kitty_mod+enter" = "launch --cwd=current";
      };

      settings = {
        linux_display_server = "wayland";
        background_opacity = "1.0";
        bold_font = "Hasklug Medium Nerd Font Complete Mono";
        copy_on_select = true;
        enable_audio_bell = false;
        enabled_layouts = "vertical,fat,grid";
        # Fat -- One (or optionally more) windows are shown full width on the top, the rest of the windows are shown side-by-side on the bottom
        # Grid -- All windows are shown in a grid
        # Horizontal -- All windows are shown side-by-side
        # Splits -- Windows arranged in arbitrary patterns created using horizontal and vertical splits
        # Stack -- Only a single maximized window is shown at a time
        # Tall -- One (or optionally more) windows are shown full height on the left, the rest of the windows are shown one below the other on the right
        # Vertical -- All windows are shown one below the other
        font_size = "13.0";
        hide_window_decorations = true;
        inactive_text_alpha = "0.65";
        macos_show_window_title_in = "none";
        scrollback_lines = "30000";
        strip_trailing_spaces = "smart";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        term = "xterm-256color";
        update_check_interval = "0";
        window_border_width = "0.0pt";
        window_margin_width = "7";
      };
    };
  };
}
