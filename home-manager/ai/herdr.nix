{
  config,
  lib,
  pkgs,
  ...
}:
let
  # herdr-projects' key, tab-bar count and sidebar rows follow whether
  # herdr-projects.nix is imported (it owns this link).
  herdrProjects = config.home.file ? ".local/bin/herdr-projects";

  # Agent or shell tab at the active pane's directory; herdr-plus.nix offers
  # the same launchers as quick actions.
  newTab = pkgs.callPackage ./bin/herdr-new-tab.nix { };

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

            [worktrees]
            # Under ~/source so a checkout's .envrc `source_up` reaches
            # ~/source/.envrc (API keys, GitHub token, sticky AWS profile).
            # direnv whitelists this root (cli/zsh.nix); herdr-arc uses it too.
            directory = "~/source/worktrees"

            [keys]
            # Each entry replaces that action's prefix binding.
            # Tabs. No direct new_tab key (its prefix default remains): the launchers below
            # open a tab already running what it is for.
            previous_tab = "ctrl+shift+left"
            next_tab = "ctrl+shift+right"

            previous_workspace = "ctrl+shift+up"
            next_workspace = "ctrl+shift+down"

            # New space (herdr "workspace").
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

            # Launchers: each opens a new tab at the active pane's directory.
            # Claude Code: y sits beside t, and kitty keeps ctrl+shift+c for copy.
            [[keys.command]]
            key = "ctrl+shift+y"
            type = "shell"
            command = "${lib.getExe newTab} claude"
            description = "open Claude Code in a new tab"

            [[keys.command]]
            key = "ctrl+shift+o"
            type = "shell"
            command = "${lib.getExe newTab} opencode"
            description = "open OpenCode in a new tab"

            [[keys.command]]
            key = "ctrl+shift+x"
            type = "shell"
            command = "${lib.getExe newTab} codex"
            description = "open Codex in a new tab"

            [[keys.command]]
            key = "ctrl+shift+p"
            type = "shell"
            command = "${lib.getExe newTab} pi"
            description = "open Pi in a new tab"

            # A plain shell, where the old ctrl+shift+t new_tab went.
            [[keys.command]]
            key = "ctrl+shift+s"
            type = "shell"
            command = "${lib.getExe newTab} shell"
            description = "open a shell in a new tab"

      ${lib.optionalString herdrProjects ''
        # herdr-projects popup (herdr-projects.nix); upstream's default is
        # prefix+a, made a direct chord like the rest.
        [[keys.command]]
        key = "ctrl+shift+a"
        type = "plugin_action"
        command = "herdr-projects.open-popup"
        description = "Projects"
      ''}
            # herdr-plus (herdr-plus.nix): workspace templates and quick actions.
            [[keys.command]]
            key = "ctrl+shift+g"
            type = "plugin_action"
            command = "cloudmanic.herdr-plus.projects"
            description = "herdr-plus: projects"

            [[keys.command]]
            key = "ctrl+shift+e"
            type = "plugin_action"
            command = "cloudmanic.herdr-plus.quick-actions"
            description = "herdr-plus: quick actions"

            [ui]
            # Skip the name prompt and create tabs immediately with generated names.
            prompt_new_tab_name = false
            pane_borders = true
            pane_outer_borders = false
            pane_gaps = false
            status_indicators = "symbols"

            # Navigation accent; focused rows use the built-in theme's active_row_bg.
            accent = "#fe8019"

      ${lib.optionalString herdrProjects ''
        # "projects: N need you" from herdr-projects, through the stable link
        # herdr-projects.nix owns. Entries match what `herdr-projects configure`
        # writes; it cannot edit this read-only file itself.
        tab_bar_right = [
          { type = "command", command = "${config.home.homeDirectory}/.local/bin/herdr-projects --root ${config.home.homeDirectory}/.herdr-projects needs-you --line", interval_seconds = 15, timeout_seconds = 5 },
        ]
      ''}
            [ui.sidebar.agents]
            row_gap = 1
            rows = [
              ["state_icon", "workspace"],
              ["terminal_title","pane"],
            ${lib.optionalString herdrProjects ''
              # herdr-projects: a thread's state and last activity.
              [{ token = "$hp_sub", dim = true }],
            ''}]

            [ui.sidebar.spaces]
            row_gap = 1
      ${lib.optionalString herdrProjects ''
        # herdr-projects' Space card: a project's home Space (label ending in
        # U+2800) is bold, the head of its group.
        rows = [
          ["state_icon", { token = "workspace", rules = [{ contains = "\u2800", bold = true }] }, { token = "branch", dim = true }, "git_status"],
        ]
      ''}
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
