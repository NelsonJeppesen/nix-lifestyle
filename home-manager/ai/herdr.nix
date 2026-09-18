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

  # Agent launcher aliases.
  programs.zsh.shellAliases = {
    h = "herdr"; # start or attach the multiplexer server
    hr = "herdr --remote"; # attach to a remote herdr over ssh
    ho = "herdr integration install opencode"; # (re)install the opencode agent-state plugin
  };

  home.file = {
    # Declarative herdr config.
    ".config/herdr/config.toml".text = ''
      # Managed by home-manager (herdr.nix).
      # Skip the first-run onboarding/notification-setup screen.
      onboarding = false

      [theme]
      # Follow kitty's reported light/dark appearance.
      auto_switch = true
      dark_name = "gruvbox"
      light_name = "gruvbox-light"

      [theme.custom]
      # Follow Kitty’s background.
      panel_bg = "reset"

      # Use each built-in theme's active_row_bg/selection_bg and foregrounds.
      [update]
      # Nix owns herdr's version; silence the background update nag. `herdr
      # update` is a no-op for a Nix-managed install anyway.
      channel = "stable"
      version_check = false

      [terminal]
      # Inherit the active pane’s directory.
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

      # New space (herdr "workspace"): mirrors new_tab's ctrl+shift+t by adding shift-n beneath it.
      new_workspace = "ctrl+shift+n"

      previous_agent = "ctrl+shift+["
      next_agent = "ctrl+shift+]"

      # Toggle the agent sidebar.
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
      # Cycle pane focus through the layout, either direction.
      cycle_pane_next = "ctrl+shift+period"
      cycle_pane_previous = "ctrl+shift+comma"

      # Launch OpenCode in a new tab.
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
      # Render inline images via the Kitty graphics protocol.
      kitty_graphics = true
    '';

    # Keybinding reference.
    ".config/herdr/usage.txt".source = ./dotfiles/herdr-usage.txt;

    ".config/opencode/skills/herdr/SKILL.md" = {
      source = "${pkgs.herdr}/share/skills/herdr/herdr/SKILL.md";
      # Replace the unmanaged file written by the previous activation hook.
      force = true;
    };
  };

  # Install (and keep updated) the herdr↔opencode integration plugin.
  home.activation.herdrOpencodeIntegration = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -d "${config.home.homeDirectory}/.config/opencode" ]; then
      if ! $DRY_RUN_CMD ${lib.getExe pkgs.herdr} integration install opencode; then
        warnEcho "Herdr OpenCode integration failed; retry 'herdr integration install opencode' and restart OpenCode."
      fi
    else
      warnEcho "Herdr OpenCode integration skipped: ~/.config/opencode is missing."
    fi
  '';

  # Pin fresh plugin installs, verify registration, and warn rather than migrate existing relay state.
  home.activation.herdrMobileRelay = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ! $DRY_RUN_CMD ${lib.getExe mobileRelayEnsure} ${lib.getExe pkgs.bash}; then
      warnEcho "Herdr mobile relay verification failed unexpectedly; inspect the activation output."
    fi
  '';
}
