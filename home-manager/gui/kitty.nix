{ pkgs, ... }:
let
  kitty-theme-test = pkgs.writeShellApplication {
    name = "kitty-theme-test";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fzf
      pkgs.kitty
    ];
    text = ''
      themes=${pkgs.kitty-themes}/share/kitty-themes/themes
      random=false
      filter=""

      usage() {
        printf 'Usage: kitty-theme-test [--random] [--light|--dark]\n'
      }

      while (( $# )); do
        case "$1" in
          --random) random=true ;;
          --light)
            [[ -z "$filter" ]] || { usage >&2; exit 2; }
            filter='[Ll]ight'
            ;;
          --dark)
            [[ -z "$filter" ]] || { usage >&2; exit 2; }
            filter='[Dd]ark'
            ;;
          -h|--help)
            usage
            exit
            ;;
          *)
            usage >&2
            exit 2
            ;;
        esac
        shift
      done

      socket="''${KITTY_LISTEN_ON:-}"
      socket="''${socket#unix:}"
      if [[ -z "''${KITTY_LISTEN_ON:-}" ]] || ! kitty @ --to "unix:$socket" ls >/dev/null 2>&1; then
        socket=""
        shopt -s nullglob
        for candidate in /tmp/kitty-*; do
          if [[ -S "$candidate" && -O "$candidate" ]] \
            && kitty @ --to "unix:$candidate" ls >/dev/null 2>&1 \
            && [[ -z "$socket" || "$candidate" -nt "$socket" ]]; then
            socket="$candidate"
          fi
        done
        if [[ -z "$socket" ]]; then
          printf 'No live Kitty remote-control socket found\n' >&2
          exit 1
        fi
      fi
      kitty_remote=(kitty @ --to "unix:$socket")

      theme_list() {
        for theme in "$themes"/*.conf; do
          if [[ -z "$filter" || "''${theme##*/}" =~ $filter ]]; then
            printf '%s\n' "$theme"
          fi
        done
      }

      if [[ "$random" == true ]]; then
        while IFS= read -r theme; do
          printf '%s\n' "''${theme##*/}"
          "''${kitty_remote[@]}" set-colors --all "$theme"
          sleep 2
        done < <(theme_list | shuf)
        exit
      fi

      selection="$(theme_list | fzf \
        --delimiter=/ \
        --with-nth=-1 \
        --prompt='Kitty theme: ' \
        --preview-window=hidden \
        --preview="kitty @ --to 'unix:$socket' set-colors --all {}")" || {
          "''${kitty_remote[@]}" set-colors --reset
          exit
        }

      "''${kitty_remote[@]}" set-colors --all "$selection"
      printf 'Using %s until Kitty restarts or reloads its config\n' "''${selection##*/}"
    '';
  };

  kitty-font-test = pkgs.writeShellApplication {
    name = "kitty-font-test";
    runtimeInputs = [ pkgs.kitty ];
    text = ''
      fonts=(
        "Adwaita Mono"
        "Cascadia Mono"
        "CommitMono"
        "Fira Code"
        "Hack"
        "IBM Plex Mono"
        "Intel One Mono"
        "Inconsolata"
        "Iosevka"
        "JetBrains Mono"
        "Maple Mono"
        "Monaspace Neon"
        "Rec Mono Linear"
        "Source Code Pro"
        "Victor Mono"
        "Anonymous Pro"
        "Atkinson Monolegible"
        "B612 Mono"
        "Comic Mono"
        "Departure Mono"
        "Fantasque Sans Mono"
        "Geist Mono"
        "Hermit"
        "iA Writer Mono V"
        "JuliaMono"
        "Lilex"
        "Meslo LG M"
        "Monoid"
        "Office Code Pro"
        "Roboto Mono"
      )

      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}"
      state_file="$state_dir/kitty-font-test"

      socket="''${KITTY_LISTEN_ON:-}"
      socket="''${socket#unix:}"
      if [[ -z "''${KITTY_LISTEN_ON:-}" ]] || ! kitty @ --to "unix:$socket" ls >/dev/null 2>&1; then
        socket=""
        shopt -s nullglob
        for candidate in /tmp/kitty-*; do
          if [[ -S "$candidate" && -O "$candidate" ]] \
            && kitty @ --to "unix:$candidate" ls >/dev/null 2>&1 \
            && [[ -z "$socket" || "$candidate" -nt "$socket" ]]; then
            socket="$candidate"
          fi
        done
        if [[ -z "$socket" ]]; then
          printf 'No live Kitty remote-control socket found\n' >&2
          exit 1
        fi
      fi
      kitty_remote=(kitty @ --to "unix:$socket")

      list_fonts() {
        for i in "''${!fonts[@]}"; do
          printf '%2d  %s\n' "$((i + 1))" "''${fonts[$i]}"
        done
      }

      case "''${1:-next}" in
        list|-l|--list)
          list_fonts
          exit
          ;;
        reset)
          "''${kitty_remote[@]}" load-config --ignore-overrides
          rm -f "$state_file"
          printf 'Restored font from kitty.conf\n'
          exit
          ;;
        next|prev)
          index=0
          if [[ -r "$state_file" ]]; then
            read -r index < "$state_file"
          fi
          if [[ "''${1:-next}" == next ]]; then
            index=$((index % ''${#fonts[@]} + 1))
          else
            index=$(((index + ''${#fonts[@]} - 2) % ''${#fonts[@]} + 1))
          fi
          ;;
        *)
          if [[ "$1" =~ ^[0-9]+$ ]] && ((1 <= $1 && $1 <= ''${#fonts[@]})); then
            index=$1
          else
            index=0
            for i in "''${!fonts[@]}"; do
              if [[ "''${fonts[$i],,}" == *"''${1,,}"* ]]; then
                index=$((i + 1))
                break
              fi
            done
            if ((index == 0)); then
              printf 'Unknown font: %s\n\n' "$1" >&2
              list_fonts >&2
              exit 1
            fi
          fi
          ;;
      esac

      family="''${fonts[$((index - 1))]}"
      "''${kitty_remote[@]}" load-config \
        --override "font_family=family='$family'" \
        --override bold_font=auto \
        --override italic_font=auto \
        --override bold_italic_font=auto
      mkdir -p "$state_dir"
      printf '%s\n' "$index" > "$state_file"
      printf '%d/%d  %s\n' "$index" "''${#fonts[@]}" "$family"
    '';
  };
in
{
  home.packages = [
    kitty-theme-test # Interactively preview Kitty themes without changing managed config
    kitty-font-test # Cycle through programming fonts using Kitty remote control

    pkgs.adwaita-fonts
    pkgs.cascadia-code
    pkgs.commit-mono
    pkgs.fira-code
    pkgs.hack-font
    pkgs.ibm-plex.mono
    pkgs.intel-one-mono
    pkgs.inconsolata
    pkgs.iosevka
    pkgs.jetbrains-mono
    pkgs.maple-mono.truetype
    pkgs.monaspace
    pkgs.recursive
    pkgs.source-code-pro
    pkgs.victor-mono
    pkgs.anonymousPro
    pkgs.atkinson-monolegible
    pkgs.b612
    pkgs.comic-mono
    pkgs.departure-mono
    pkgs.fantasque-sans-mono
    pkgs.geist-font
    pkgs.hermit
    pkgs.ia-writer-mono
    pkgs.julia-mono
    pkgs.lilex
    pkgs.meslo-lg
    pkgs.monoid
    pkgs.office-code-pro
    pkgs.roboto-mono
  ];

  home = {
    file = {
      # Follow the desktop color scheme.
      ".config/kitty/dark-theme.auto.conf".source =
        pkgs.kitty-themes + "/share/kitty-themes/themes/everforest_dark_hard.conf";

      # Use soft Everforest outside dark mode.
      ".config/kitty/no-preference-theme.auto.conf".source =
        pkgs.kitty-themes + "/share/kitty-themes/themes/everforest_dark_soft.conf";
      ".config/kitty/light-theme.auto.conf".source =
        pkgs.kitty-themes + "/share/kitty-themes/themes/everforest_dark_soft.conf";
    };
  };

  programs = {
    kitty = {
      enable = true;

      # Source kitty's zsh integration fragment from .zshrc.
      shellIntegration = {
        enableZshIntegration = true;
        mode = "no-cursor"; # equivalent to old `shell_integration = "no-cursor"`
      };

      keybindings = {
        # Clipboard
        "kitty_mod+c" = "copy_to_clipboard";
        "kitty_mod+v" = "paste_from_clipboard";

        # Font size — kitty's own defaults, re-added after the clear. Reset
        # (kitty_mod+backspace) is intentionally omitted; see the note above.
        "kitty_mod+equal" = "change_font_size all +2.0";
        "kitty_mod+plus" = "change_font_size all +2.0";
        "kitty_mod+minus" = "change_font_size all -2.0";

      };

      #  Terminal settings
      settings = {

        # Drop ALL of kitty's built-in keyboard shortcuts, keeping only the allowlist mapped above.
        clear_all_shortcuts = "yes";

        # Lilex with Nerd Font symbols.
        #bold_font = "Inconsolata Medium";
        #bold_italic_font = "Fira Code, Regular Italic";
        #italic_font = "Fira Code, Regular Italic";
        #font_family = "Inconsolata Medium";
        font_family = "family='Lilex'";
        font_size = 14.5;

        window_margin_width = 0;

        # Map Nerd Font symbols.
        symbol_map =
          "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,"
          + "U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,"
          + "U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,"
          + "U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 Symbols Nerd Font Mono";

        copy_on_select = true; # Auto-copy selected text to clipboard
        enable_audio_bell = false; # Silence terminal bell
        hide_window_decorations = true; # Remove title bar (GNOME handles window chrome)

        linux_display_server = "wayland"; # Force Wayland (no XWayland fallback)

        # Rendering latency.
        input_delay = "0";
        # repaint_delay: ms between screen repaints. Default 10; 8 tightens the
        # repaint cadence (~125fps cap) for visibly smoother scroll/output.
        repaint_delay = "8";
        # Synchronize repaints with vblank.
        sync_to_monitor = "yes";

        scrollback_lines = 30000; # 30K lines of scrollback buffer
        strip_trailing_spaces = "smart";
        # herdr draws its own tab/pane chrome, so hide kitty's tab bar entirely.
        tab_bar_style = "hidden";

        # Allow OSC52 clipboard access.
        clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask no-append";

        # Enable remote theme control.
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty-{kitty_pid}";

        update_check_interval = 0; # Disable update checks (managed by Nix)

        # NOTE: `term` is intentionally NOT set.
      };
    };
  };
}
