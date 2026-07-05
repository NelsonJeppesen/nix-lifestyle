# herdr.nix - herdr agent multiplexer
#
# herdr (https://herdr.dev) is a tmux-style terminal multiplexer built for AI
# coding agents. It runs each agent in a real pane on a background server that
# survives detach, and rolls every agent up to a blocked / working / done /
# idle state in its sidebar. It does NOT replace opencode — it is the terminal
# you launch opencode (and any other agent) inside of. opencode.nix is left
# untouched; this module only adds the wrapper around it.
#
# Keybindings: herdr binds ONE key per action. Rather than lean on the tmux
# ctrl+b prefix, the common actions are remapped to direct ctrl+shift chords
# that mirror the kitty.nix muscle memory (new tab = ctrl+shift+t, and so on).
# kitty.nix clears its own shortcuts down to a small allowlist (copy/paste,
# font-size, F1), so the whole ctrl+shift space passes through kitty to herdr;
# GNOME leaves plain ctrl+shift+arrows unbound (its workspace chords all add
# Alt or Super), so nothing has to be freed there either. Actions left unlisted
# keep their prefix defaults (prefix = ctrl+b): workspace picker prefix+w,
# detach prefix+q, resize prefix+r, copy-mode prefix+[, help prefix+?, and so
# on — run `herdr --default-config` to see them all.
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
  # Helper bound to ctrl+shift+o (see [[keys.command]] below): open opencode in a
  # fresh herdr tab that inherits the focused pane's working directory, so
  # opencode loads the project's .opencode/ config and any direnv-provided
  # creds. herdr has no native "new tab running X" command, so this drives the
  # CLI: it creates a focused tab, reads the new root pane id from the JSON
  # reply, and starts opencode there. herdr runs it detached (type = "shell").
  ocNewTab = pkgs.writeShellApplication {
    name = "herdr-oc-new-tab";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = ''
      # HERDR_PANE_ID is set by herdr to the pane that triggered the chord;
      # follow its foreground cwd so the new tab opens in the same directory.
      cwd=""
      if [ -n "''${HERDR_PANE_ID:-}" ]; then
        cwd="$(herdr pane get "$HERDR_PANE_ID" \
          | jq -r '.result.pane.foreground_cwd // .result.pane.cwd // empty')"
      fi
      if [ -n "$cwd" ]; then
        pane="$(herdr tab create --focus --cwd "$cwd" | jq -r '.result.root_pane.pane_id')"
      else
        pane="$(herdr tab create --focus | jq -r '.result.root_pane.pane_id')"
      fi
      exec herdr pane run "$pane" opencode
    '';
  };
in
{
  # herdr binary (0.7.1 in the pinned nixpkgs). Installed via home.packages so
  # updates flow through the flake, not herdr's own curl|sh installer.
  home.packages = [ pkgs.herdr ];

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
      # herdr uses gruvbox regardless of the desktop light/dark preference
      # (kitty keeps its own rose-pine pair in kitty.nix). A single fixed theme,
      # so auto_switch is left off (its default) and no light/dark pair is set.
      name = "gruvbox"

      [update]
      # Nix owns herdr's version; silence the background update nag. `herdr
      # update` is a no-op for a Nix-managed install anyway.
      version_check = false

      [terminal]
      # New panes/tabs/workspaces inherit the source pane's cwd, matching the
      # `--cwd=current` habit from kitty.nix.
      new_cwd = "follow"

      [keys]
      # herdr binds ONE key per action, so each entry REPLACES that action's
      # prefix default with a single direct ctrl+shift chord. kitty.nix clears
      # its own shortcuts (keeping only copy/paste, font-size and F1), so these
      # ctrl+shift chords pass straight through kitty to herdr. Actions not
      # listed here keep their prefix defaults — run `herdr --default-config`
      # to see the full set.

      # Tabs — new tab reuses kitty's own ctrl+shift+t muscle memory; [ / ]
      # step through the tab strip.
      new_tab = "ctrl+shift+t"
      previous_tab = "ctrl+shift+left"
      next_tab = "ctrl+shift+right"

      previous_workspace = "ctrl+shift+up"
      next_workspace = "ctrl+shift+down"

      previous_agent = "ctrl+shift+["
      next_agent = "ctrl+shift+]"

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
      cycle_pane_next = "ctrl+shift+tab"

      # Quick agent launch: open opencode in a NEW tab (not a throwaway pane),
      # landing in the focused pane's directory. type = "shell" runs the helper
      # detached; it creates the tab and starts opencode in it (see ocNewTab).
      [[keys.command]]
      key = "ctrl+shift+o"
      type = "shell"
      command = "${lib.getExe ocNewTab}"
      description = "open opencode in a new tab"

      [ui]
      # Skip the name prompt and create tabs immediately with generated names.
      prompt_new_tab_name = false
      pane_gaps = false

      [experimental]
      # Render inline images via the Kitty graphics protocol. kitty is the outer
      # terminal here, so the graphics-compatible requirement is satisfied.
      kitty_graphics = true
    '';

    # Plain-text keybindings / usage cheatsheet, symlinked into the herdr
    # config dir so it sits next to config.toml. Source of truth is the repo
    # dotfile (matches the curlrc / digrc pattern in home.nix).
    ".config/herdr/usage.txt".source = ./dotfiles/herdr-usage.txt;
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
      $DRY_RUN_CMD ${lib.getExe pkgs.herdr} integration install opencode || true
    fi
  '';
}
