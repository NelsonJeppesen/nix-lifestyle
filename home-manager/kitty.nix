# kitty.nix - Kitty terminal emulator configuration
#
# kitty is intentionally a "dumb" single-window terminal here: herdr (herdr.nix)
# owns all multiplexing — tabs, splits, panes, sessions. kitty therefore clears
# its own shortcuts down to a tiny allowlist (copy/paste, font-size, F1) so the
# whole ctrl+shift chord space passes through to herdr, and hides its tab bar.
#
# Configures the Kitty GPU-accelerated terminal with:
# - Adwaita Mono font (matching GNOME system font) with Nerd Font symbol mapping
# - Wayland-native display with IME disabled (reduces latency)
# - Minimal keybindings: copy/paste, font-size, and buffer-to-nvim piping (F1)
# - Rose Pine (Moon for light / no-preference) auto-switching via kitty's themes
# - Tab bar hidden (herdr draws its own); 30K scrollback, copy-on-select,
#   and stripped trailing whitespace
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
      # Pair: Rose Pine (dark) / Rose Pine Moon (light and no-preference).
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
      # clear_all_shortcuts (settings below) drops every kitty default so the
      # ctrl+shift chord space is free for herdr. Only this allowlist is kept,
      # and all of it stays clear of the keys herdr binds (see herdr.nix).
      # kitty_mod is ctrl+shift, so these are the usual ctrl+shift+c/v/±.
      #
      # NOTE: ctrl+shift+backspace is deliberately NOT re-added here. kitty's
      # default binds it to font-size reset, but herdr binds it to close_pane
      # (herdr.nix). Because kitty grabs a chord before forwarding it, keeping
      # the font-reset binding would swallow the key and herdr would never see
      # it — so we drop it and let ctrl+shift+backspace pass through to herdr.
      # Font-size reset is still reachable via `change_font_size` from kitty's
      # remote control if ever needed.
      keybindings = {
        # Clipboard
        "kitty_mod+c" = "copy_to_clipboard";
        "kitty_mod+v" = "paste_from_clipboard";

        # Font size — kitty's own defaults, re-added after the clear. Reset
        # (kitty_mod+backspace) is intentionally omitted; see the note above.
        "kitty_mod+equal" = "change_font_size all +2.0";
        "kitty_mod+plus" = "change_font_size all +2.0";
        "kitty_mod+minus" = "change_font_size all -2.0";

        # F1: pipe entire scrollback buffer into nvim in a split
        # Useful for searching/copying terminal output with vim motions
        "f1" =
          "launch --stdin-source=@screen_scrollback --location=hsplit --cwd=current nvim -c 'set buftype=nofile' -";
      };

      # ── Terminal settings ───────────────────────────────────────
      settings = {

        # Drop ALL of kitty's built-in keyboard shortcuts, keeping only the
        # allowlist mapped above. home-manager emits settings before the `map`
        # lines, so this clear runs first and the allowlist survives it. Frees
        # the whole ctrl+shift chord space for herdr (herdr.nix).
        clear_all_shortcuts = "yes";

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

        # ── Input/render latency tuning (snappiness) ────────────────
        # input_delay: ms kitty waits to batch keyboard input before sending
        # it to the program. Default 3; 0 forwards each keystroke immediately
        # for the lowest possible keystroke->program latency (nvim, opencode).
        input_delay = "0";
        # repaint_delay: ms between screen repaints. Default 10; 8 tightens the
        # repaint cadence (~125fps cap) for visibly smoother scroll/output.
        repaint_delay = "8";
        # sync_to_monitor: align repaints to the monitor's vblank to eliminate
        # tearing. Costs up to one frame of latency but keeps output clean;
        # the input_delay=0 above keeps *keystroke* latency unaffected by this.
        sync_to_monitor = "yes";

        scrollback_lines = 30000; # 30K lines of scrollback buffer
        strip_trailing_spaces = "always"; # Remove trailing whitespace on copy
        # herdr draws its own tab/pane chrome, so hide kitty's tab bar entirely.
        tab_bar_style = "hidden";

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
