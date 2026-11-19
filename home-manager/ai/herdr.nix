# Own Herdr UI, keybindings, launchers, and integration reconciliation through Home Manager.
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

  # Agent and shell launchers open tabs at the active pane's directory.
  newTab = pkgs.callPackage ./bin/herdr-new-tab.nix { };

  # herdr-plus's "ARC: Close worktree + ticket" quick action on a direct key.
  # herdr-plus can only bind its whole quick-actions menu, so this popup runs
  # that action's own list and close commands, with fzf as the picker. Inside
  # an ARC Space it skips the picker and closes that one (close still asks).
  arcClose = pkgs.writeShellApplication {
    name = "herdr-arc-close";
    runtimeInputs = [
      (pkgs.callPackage ./bin/herdr-arc.nix { hmConfig = config; })
      pkgs.fzf
    ];
    text = ''
      devops=${config.home.homeDirectory}/source/devops
      current="$(herdr-arc current "$devops")"
      if [ -n "$current" ]; then
        exec herdr-arc close "$devops" "$current"
      fi
      worktrees="$(herdr-arc list "$devops" worktrees)"
      if [ -z "$worktrees" ]; then
        echo "No ARC worktrees to close · Enter closes"
        read -r _ </dev/tty || true
        exit 0
      fi
      choice="$(fzf --prompt 'Close ARC worktree: ' <<<"$worktrees")" || exit 0
      exec herdr-arc close "$devops" "''${choice%%$'\t'*}"
    '';
  };

in
{
  # Nix owns the herdr version.
  home.packages = [
    pkgs.herdr
  ];

  # Agent launcher aliases.
  programs.zsh.shellAliases = {
    h = "herdr"; # start or attach the multiplexer server
    ho = "herdr integration install opencode"; # (re)install the opencode agent-state plugin
  };

  home.file = {
    # Declarative herdr config.
    ".config/herdr/config.toml".text = ''
            # Managed by home-manager (herdr.nix).
            # Skip the first-run onboarding/notification-setup screen.
            onboarding = false

            [theme]
            # Use kitty's own ANSI palette, so herdr follows kitty's light/dark
            # themes (gui/kitty.nix) instead of carrying its own.
            name = "terminal"
            # Switching only picks the sidebar overrides below; both sides
            # stay on kitty's palette.
            auto_switch = true
            dark_name = "terminal"
            light_name = "terminal"

            [theme.custom]
            # Follow Kitty’s background.
            panel_bg = "reset"

            # Sidebar a shade darker than the panes, selected row in kitty's
            # selection_background, per kitty theme (gui/kitty.nix). Hex, not
            # ANSI names: Suburb's color0 is its background and color8 too bright.
            [theme.custom.dark]
            # Base2Tone Suburb dark: background #1e202f.
            sidebar_bg = "#171925"
            active_row_bg = "#292c3d"

            [theme.custom.light]
            # Base2Tone Lake dark, kitty's light-mode theme: background #192d34.
            sidebar_bg = "#13232a"
            active_row_bg = "#223c44"

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

            split_horizontal = "ctrl+shift+enter"
            split_vertical = "ctrl+shift+d"

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

            # A plain shell at the active pane's working directory.
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

            # The ARC close quick action on its own key (arcClose above).
            [[keys.command]]
            key = "ctrl+shift+w"
            type = "popup"
            command = "${lib.getExe arcClose}"
            description = "ARC: close worktree + ticket"

            [ui]
            # Skip the name prompt and create tabs immediately with generated names.
            prompt_new_tab_name = false
            pane_borders = true
            pane_outer_borders = false
            pane_gaps = false
            status_indicators = "symbols"

      ${lib.optionalString herdrProjects ''
        # "projects: N need you" from herdr-projects, through the stable link
        # herdr-projects.nix owns. Entries match what `herdr-projects configure`
        # writes; it cannot edit this read-only file itself.
        tab_bar_right = [
          { type = "command", command = "${config.home.homeDirectory}/.local/bin/herdr-projects --root ${config.home.homeDirectory}/.herdr-projects needs-you --line", interval_seconds = 15, timeout_seconds = 5 },
        ]
      ''}
            [ui.toast]
            # Agent finished/needs-input popups as toasts inside herdr, not
            # desktop notifications; herdr-arc's notifications use them too.
            delivery = "herdr"

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
    # Copy into each worktree's private Git directory to record task ownership.
    ".config/herdr/worktree-handoff.md".source = ./dotfiles/worktree-handoff.md;

    ".config/opencode/skills/herdr/SKILL.md" = {
      source = "${pkgs.herdr}/share/skills/herdr/herdr/SKILL.md";
      # Keep this skill owned by Home Manager even if an integration installer writes it.
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

}
