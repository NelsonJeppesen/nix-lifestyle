# herdr.nix - herdr agent multiplexer
#
# herdr (https://herdr.dev) is a tmux-style terminal multiplexer built for AI
# coding agents. It runs each agent in a real pane on a background server that
# survives detach, and rolls every agent up to a blocked / working / done /
# idle state in its sidebar. It does NOT replace opencode — it is the terminal
# you launch opencode (and any other agent) inside of. opencode.nix is left
# untouched; this module only adds the wrapper around it.
#
# Keybindings: herdr is prefix-driven (ctrl+b <key>, like tmux). To keep the
# muscle memory from kitty.nix (which uses ctrl+shift chords), every common
# action ALSO gets a direct ctrl+alt chord here. ctrl+alt is the one modifier
# family herdr's docs certify as safe across terminals — it does not collide
# with kitty's ctrl+shift bindings, survives terminals without the modern
# keyboard protocol, and (unlike plain alt) is not eaten by macOS option-key
# composing. The ctrl+b prefix bindings are kept as-is on top of the chords.
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
{
  # herdr binary (0.7.0 in the pinned nixpkgs). Installed via home.packages so
  # updates flow through the flake, not herdr's own curl|sh installer.
  home.packages = [ pkgs.herdr ];

  # Shell aliases for quick access. Kept in this module (not zsh.nix) per the
  # repo rule: extend by adding a new <feature>.nix. The opencode aliases
  # (o/oc/or/…) stay in opencode.nix; you run those inside an `h` session.
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

      [theme]
      # Follow the kitty rose-pine pair (kitty.nix) and switch with the
      # desktop's light/dark preference, the same signal kitty reads.
      name = "rose-pine"
      auto_switch = true
      light_name = "rose-pine-dawn"
      dark_name = "rose-pine"

      [update]
      # Nix owns herdr's version; silence the background update nag. `herdr
      # update` is a no-op for a Nix-managed install anyway.
      version_check = false

      [terminal]
      # New panes/tabs/workspaces inherit the source pane's cwd, matching the
      # `--cwd=current` habit from kitty.nix.
      new_cwd = "follow"

      [keys]
      # Prefix defaults are kept; each line adds a direct ctrl+alt chord that
      # mirrors the kitty.nix action so the muscle memory carries over.
      # (prefix = ctrl+b; press it, release, then the action key.)

      # Tabs — kitty: ctrl+shift+n new, ctrl+shift+left/right cycle.
      new_tab = ["prefix+c", "ctrl+alt+c"]
      previous_tab = ["prefix+p", "ctrl+alt+["]
      next_tab = ["prefix+n", "ctrl+alt+]"]

      # Pane focus — kitty: ctrl+shift+up/down cycle windows. h/j/k/l here.
      focus_pane_left = ["prefix+h", "ctrl+alt+h"]
      focus_pane_down = ["prefix+j", "ctrl+alt+j"]
      focus_pane_up = ["prefix+k", "ctrl+alt+k"]
      # NOTE: ctrl+alt+l is the KDE lock-screen chord. This host is GNOME
      # (gnome.nix), where it is unbound, so it is safe here. Revisit if this
      # config is ever reused on KDE.
      focus_pane_right = ["prefix+l", "ctrl+alt+l"]

      # Splits — kitty: ctrl+shift+enter opens a new window (a vertical split).
      # herdr has no horizontal-split equivalent in kitty, so the horizontal
      # chord uses herdr's own documented safe fallback (ctrl+alt+shift+d).
      split_vertical = ["prefix+v", "ctrl+alt+enter"]
      split_horizontal = ["prefix+minus", "ctrl+alt+shift+d"]

      # Pane lifecycle — kitty: ctrl+shift+backspace closes a window;
      # ctrl+shift+] cycles layout (mapped to next-pane cycling here).
      close_pane = ["prefix+x", "ctrl+alt+x"]
      zoom = ["prefix+z", "ctrl+alt+z"]
      cycle_pane_next = ["prefix+tab", "ctrl+alt+tab"]

      # Quick agent launch: open a temporary pane running opencode. Closes when
      # opencode exits. prefix+alt+o keeps it off the direct-chord space.
      [[keys.command]]
      key = "prefix+alt+o"
      type = "pane"
      command = "opencode"
      description = "launch opencode in a pane"
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
