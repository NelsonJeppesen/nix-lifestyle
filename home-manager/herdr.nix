# herdr.nix - herdr agent multiplexer
#
# herdr (https://herdr.dev) is a tmux-style terminal multiplexer built for AI
# coding agents. It runs each agent in a real pane on a background server that
# survives detach, and rolls every agent up to a blocked / working / done /
# idle state in its sidebar. It does NOT replace opencode — it is the terminal
# you launch opencode (and any other agent) inside of. opencode.nix is left
# untouched; this module only adds the wrapper around it.
#
# Common actions use direct ctrl+shift chords. Kitty keeps only clipboard and
# font-size shortcuts, so the rest reach herdr. Unlisted actions keep their
# ctrl+b prefix defaults; `prefix+?` shows the live keymap.
#
# Config lives at ~/.config/herdr/config.toml. herdr has no home-manager
# module, so the TOML is rendered directly via home.file. `herdr
# server reload-config` (or `prefix+shift+r`) reloads most of it live.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Open OpenCode in a new tab at the active pane's directory.
  ocNewTab = pkgs.writeShellApplication {
    name = "herdr-oc-new-tab";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = ''
      workspace="''${HERDR_ACTIVE_WORKSPACE_ID:?Herdr did not supply the active workspace}"
      cwd="''${HERDR_ACTIVE_PANE_CWD:?Herdr did not supply the active directory}"
      pane="$(herdr tab create --workspace "$workspace" --focus --cwd "$cwd" \
        | jq -er '.result.root_pane.pane_id | strings | select(length > 0)')"
      name="oc-''${pane//:/-}"
      exec herdr agent start "''${name,,}" --kind opencode --pane "$pane"
    '';
  };

  # Open Pi in a new tab at the active pane's directory.
  piNewTab = pkgs.writeShellApplication {
    name = "herdr-pi-new-tab";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = ''
      workspace="''${HERDR_ACTIVE_WORKSPACE_ID:?Herdr did not supply the active workspace}"
      cwd="''${HERDR_ACTIVE_PANE_CWD:?Herdr did not supply the active directory}"
      pane="$(herdr tab create --workspace "$workspace" --focus --cwd "$cwd" \
        | jq -er '.result.root_pane.pane_id | strings | select(length > 0)')"
      name="pi-''${pane//:/-}"
      exec herdr agent start "''${name,,}" --kind pi --pane "$pane"
    '';
  };

  mobileRelayEnsure = pkgs.writeShellApplication {
    name = "herdr-mobile-relay-ensure";
    runtimeInputs = with pkgs; [
      herdr
      jq
      bash
      gnused
      coreutils
    ];
    text = builtins.readFile ./bin/herdr-mobile-relay-ensure;
  };
in
{
  # Nix owns the herdr version.
  home.packages = [
    pkgs.cloudflared # Public HTTPS/WSS tunnel for the mobile relay
    pkgs.herdr
    pkgs.uv # Isolated Python runtime used by the mobile relay
  ];

  # Shell aliases for quick access. Kept in this module (not zsh.nix) per the
  # repo rule: extend by adding a new <feature>.nix. The opencode aliases
  # (o/oc/ou/…) stay in opencode.nix; you run those inside an `h` session.
  programs.zsh.shellAliases = {
    h = "herdr"; # start or attach the multiplexer server
    hr = "herdr --remote"; # attach to a remote herdr over ssh
    ho = "herdr integration install opencode"; # (re)install the opencode agent-state plugin
  };

  home.file = {
    # Declarative herdr config. herdr falls back to a safe default (with a
    # startup warning) for any invalid value, so this stays resilient.
    ".config/herdr/config.toml".text = ''
      # Managed by home-manager (herdr.nix). Do not edit by hand — changes are
      # overwritten on `home-manager switch`. Reload with `herdr server
      # reload-config` or prefix+shift+r after a rebuild.

      # Skip the first-run onboarding/notification-setup screen. This is a
      # top-level key, so it MUST stay above the first [section] header.
      onboarding = false

      [theme]
      # Follow kitty's reported light/dark appearance. kitty follows GNOME and
      # carries the matching Gruvbox dark/light pair in kitty.nix. name is left
      # unset because auto_switch drives the pair.
      auto_switch = true
      dark_name = "gruvbox"
      light_name = "gruvbox-light"

      [theme.custom]
      # Inherit Kitty's active background so herdr remains visually seamless
      # when Kitty switches between the managed dark/light theme files.
      panel_bg = "reset"

      # Use each built-in theme's active_row_bg/selection_bg and foregrounds.
      # Shared dark-only overrides would also apply in light mode.

      [update]
      # Nix owns herdr's version; silence the background update nag. `herdr
      # update` is a no-op for a Nix-managed install anyway.
      channel = "stable"
      version_check = false

      [terminal]
      # New panes/tabs/workspaces inherit the source pane's cwd, matching the
      # `--cwd=current` habit from kitty.nix. herdr has only this single
      # policy, so new workspaces default to ~/source via the `ws` shell
      # alias (shellAliases in zsh.nix) rather than this key.
      new_cwd = "follow"

      [keys]
      # Each entry replaces that action's prefix binding.

      # Tabs — new tab reuses kitty's own ctrl+shift+t muscle memory; [ / ]
      # step through the tab strip.
      new_tab = "ctrl+shift+t"
      previous_tab = "ctrl+shift+left"
      next_tab = "ctrl+shift+right"

      previous_workspace = "ctrl+shift+up"
      next_workspace = "ctrl+shift+down"

      # New space (herdr "workspace"): mirrors new_tab's ctrl+shift+t by adding
      # shift-n beneath it.
      new_workspace = "ctrl+shift+n"

      previous_agent = "ctrl+shift+["
      next_agent = "ctrl+shift+]"

      # Show/hide the agent sidebar (default prefix+b) as a direct chord,
      # matching the ctrl+shift muscle memory of the actions above.
      toggle_sidebar = "ctrl+shift+b"

      # Enter resize mode (default prefix+r) as a direct chord.
      resize_mode = "ctrl+shift+r"

      # Edit scrollback in the configured editor.
      edit_scrollback = "f1"

      # Pane focus — h/j/k/l vim motions.
      focus_pane_left = "ctrl+shift+h"
      focus_pane_down = "ctrl+shift+j"
      focus_pane_up = "ctrl+shift+k"
      focus_pane_right = "ctrl+shift+l"

      # Splits — vertical reuses kitty's ctrl+shift+enter "new window" muscle
      # memory; horizontal is the natural ctrl+shift+d beneath it.
      split_vertical = "ctrl+shift+enter"
      split_horizontal = "ctrl+shift+d"

      # Pane lifecycle.
      close_pane = "ctrl+shift+backspace"
      zoom = "ctrl+shift+z"
      # Cycle pane focus through the layout, either direction. comma/period
      # (< / >) read as step-back / step-forward and are easy adjacent keys.
      cycle_pane_next = "ctrl+shift+period"
      cycle_pane_previous = "ctrl+shift+comma"

      # Quick agent launch: open opencode in a NEW tab (not a throwaway pane),
      # landing in the focused pane's directory. type = "shell" runs the helper
      # detached; it creates the tab and starts opencode in it (see ocNewTab).
      [[keys.command]]
      key = "ctrl+shift+o"
      type = "shell"
      command = "${lib.getExe ocNewTab}"
      description = "open opencode in a new tab"

      # Early Pi testing alongside OpenCode. This only adds another launcher;
      # the existing OpenCode shortcut and integration remain unchanged.
      [[keys.command]]
      key = "ctrl+shift+p"
      type = "shell"
      command = "${lib.getExe piNewTab}"
      description = "open pi in a new tab"

      [ui]
      # Skip the name prompt and create tabs immediately with generated names.
      prompt_new_tab_name = false
      pane_borders = true
      pane_outer_borders = false
      pane_gaps = false
      status_indicators = "symbols"

      # Navigation accent; focused rows use the built-in theme's active_row_bg.
      accent = "#fe8019"

      [ui.sidebar.agents]
      row_gap = 1
      rows = [["state_icon", "workspace"], ["terminal_title","pane"]]

      [ui.sidebar.spaces]
      row_gap = 1

      [experimental]
      # Render inline images via the Kitty graphics protocol. kitty is the outer
      # terminal here, so the graphics-compatible requirement is satisfied.
      kitty_graphics = true
    '';

    # Plain-text keybindings / usage cheatsheet, symlinked into the herdr
    # config dir so it sits next to config.toml. Source of truth is the repo
    # dotfile (matches the curlrc / digrc pattern in home.nix).
    ".config/herdr/usage.txt".source = ./dotfiles/herdr-usage.txt;

    ".config/opencode/skills/herdr/SKILL.md" = {
      source = "${pkgs.herdr}/share/herdr/skills/herdr/SKILL.md";
      # Replace the unmanaged file written by the previous activation hook.
      force = true;
    };
  };

  # Install (and keep updated) the herdr↔opencode integration plugin. herdr
  # writes ~/.config/opencode/plugins/herdr-agent-state.js — a versioned,
  # herdr-managed plugin that reports opencode's session state (blocked /
  # working / done) to herdr's sidebar and enables native session restore.
  #
  # Done in activation rather than by pinning a fetched copy because the plugin
  # is version-locked to the herdr binary (HERDR_INTEGRATION_VERSION) and is
  # explicitly self-described as overwritten on every reinstall — running the
  # installed herdr keeps the plugin matched to the package version. It is
  # idempotent. Ordered after the opencode module's config dir exists (the
  # installer refuses to run if ~/.config/opencode is missing).
  home.activation.herdrOpencodeIntegration = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -d "${config.home.homeDirectory}/.config/opencode" ]; then
      if ! $DRY_RUN_CMD ${lib.getExe pkgs.herdr} integration install opencode; then
        warnEcho "Herdr OpenCode integration failed; retry 'herdr integration install opencode' and restart OpenCode."
      fi
    else
      warnEcho "Herdr OpenCode integration skipped: ~/.config/opencode is missing."
    fi
  '';

  # Pin fresh plugin installs, verify registration, and warn rather than migrate
  # existing relay state. The upstream release bundle is not Nix-managed.
  home.activation.herdrMobileRelay = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ! $DRY_RUN_CMD ${lib.getExe mobileRelayEnsure} ${lib.getExe pkgs.bash}; then
      warnEcho "Herdr mobile relay verification failed unexpectedly; inspect the activation output."
    fi
  '';
}
