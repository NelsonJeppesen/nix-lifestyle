# kitty.nix - Kitty terminal emulator configuration
#
# Configures the Kitty GPU-accelerated terminal with:
# - Adwaita Mono font (matching GNOME system font) with Nerd Font symbol mapping
# - Wayland-native display with IME disabled (reduces latency)
# - Custom keybindings for tabs, windows, and buffer-to-nvim piping
# - Catppuccin Latte/Mocha auto-switching via kitty's theme system
# - Powerline-style tab bar with slanted separators
# - 30K line scrollback, copy-on-select, and stripped trailing whitespace
# - Shell integration sourced into zsh by home-manager
# - Remote control socket enabled (for `kitty @ set-colors`, etc.)
{ pkgs, ... }:
{
  home = {
    file = {
      # Startup session: open a single blank tab on launch
      ".config/kitty/kitty.startup.session".text = ''
        new_tab
        launch
      '';

      # Auto-theme files: kitty switches between these based on the desktop's
      # color-scheme preference (org.freedesktop.appearance via xdg-desktop-portal).
      # Pair: Catppuccin Latte (light) / Catppuccin Mocha (dark).
      ".config/kitty/dark-theme.auto.conf".source =
        pkgs.kitty-themes + "/share/kitty-themes/themes/rose-pine.conf";

      # On the GNOME desktop, the desktop reports the color preference as no-preference when
      # the “Dark style” is not enabled. So use no-preference-theme.auto.conf to select colors
      # for light mode on GNOME
      ".config/kitty/no-preference-theme.auto.conf".source =
        pkgs.kitty-themes + "/share/kitty-themes/themes/rose-pine-moon.conf";
      ".config/kitty/light-theme.auto.conf".source =
        pkgs.kitty-themes + "/share/kitty-themes/themes/rose-pine-moon.conf";
    };
  };

  programs = {
    kitty = {
      enable = true;

      # Source kitty's zsh integration fragment from .zshrc. Provides
      # prompt-mark / current-dir reporting (used by jump-to-prompt, OSC52
      # clipboard hand-off, and kitty's tab-title management).
      shellIntegration = {
        enableZshIntegration = true;
        mode = "no-cursor"; # equivalent to old `shell_integration = "no-cursor"`
      };

      # ── Keybindings ─────────────────────────────────────────────
      keybindings = {
        "kitty_mod+]" = "next_layout"; # Cycle through layouts

        # Window management within a tab
        "kitty_mod+backspace" = "close_window";
        "kitty_mod+enter" = "launch --cwd=current"; # New window in current directory
        "kitty_mod+up" = "prev_window";
        "kitty_mod+down" = "next_window";

        "kitty_mod+w" = "new_os_window_with_cwd"; # New OS-level window

        # Tab navigation
        "kitty_mod+left" = "prev_tab";
        "kitty_mod+right" = "next_tab";
        "kitty_mod+n" = "new_tab_with_cwd"; # New tab in current directory

        # F1: pipe entire scrollback buffer into nvim in a split
        # Useful for searching/copying terminal output with vim motions
        "f1" =
          "launch --stdin-source=@screen_scrollback --location=hsplit --cwd=current nvim -c 'set buftype=nofile' -";
      };

      # ── Terminal settings ───────────────────────────────────────
      settings = {

        # Font configuration: use GNOME's default monospace font.
        # Commented alternatives preserved for easy font experimentation.
        #bold_font = "Inconsolata Medium";
        #bold_italic_font = "Fira Code, Regular Italic";
        #italic_font = "Fira Code, Regular Italic";
        #font_family = "Inconsolata Medium";

        # Use Adwaita Mono to match GNOME system font
        font_family = "family='Adwaita Mono'";
        bold_font = "auto";
        italic_font = "auto";
        bold_italic_font = "auto";
        font_size = 17.5;

        # Window border colors (active = blue, inactive = gray)
        active_border_color = "#74B3CE";
        bell_border_color = "#ff5a00";
        inactive_border_color = "#aaaaaa";
        window_border_width = "1px";
        window_margin_width = 0;

        # Nerd Font symbol mapping: instead of using a patched font, map only
        # the Nerd Font symbol Unicode ranges to "Symbols Nerd Font Mono".
        # This keeps the main font clean while still rendering icons correctly.
        # See: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
        symbol_map =
          "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,"
          + "U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,"
          + "U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,"
          + "U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 Symbols Nerd Font Mono";

        copy_on_select = true; # Auto-copy selected text to clipboard
        enable_audio_bell = false; # Silence terminal bell
        hide_window_decorations = true; # Remove title bar (GNOME handles window chrome)

        # Disable Input Method Extensions (IME) on Wayland
        # Reduces input latency and avoids bugs with certain IME frameworks
        wayland_enable_ime = false;

        inactive_text_alpha = 0.5; # Dim inactive window text (50% opacity)
        linux_display_server = "wayland"; # Force Wayland (no XWayland fallback)
        scrollback_lines = 30000; # 30K lines of scrollback buffer
        strip_trailing_spaces = "always"; # Remove trailing whitespace on copy
        tab_bar_min_tabs = 1; # Always show tab bar (even with one tab)
        tab_bar_style = "powerline"; # Powerline-style tab bar
        tab_powerline_style = "slanted"; # Slanted separators between tabs

        # OSC52 clipboard control: allow kitty to read/write the clipboard so
        # nvim/yank-over-ssh works. `*-ask` requires a confirmation popup the
        # first time; switch to `read-clipboard read-primary` to skip it.
        clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask no-append";

        # Remote control socket: required for `kitty @ set-colors` and other
        # `kitty @` commands (used for live theme switching, etc.).
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty-{kitty_pid}";

        update_check_interval = 0; # Disable update checks (managed by Nix)

        # NOTE: `term` is intentionally NOT set. Kitty's own xterm-kitty
        # terminfo (shipped via the nixpkgs package) is required for undercurl
        # (Smulx/Setulc), styled underlines, true-color detection, and the
        # kitty graphics protocol. For SSH targets that lack the terminfo,
        # use `kitten ssh user@host` (copies terminfo to the remote on connect).
      };
    };
  };
}
