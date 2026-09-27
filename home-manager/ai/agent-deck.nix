{
  config,
  lib,
  pkgs,
  agent-deck,
  ...
}:
let
  # Upstream ships no flake and nixpkgs has no package; build the pinned tag.
  agentDeck = pkgs.buildGoModule {
    pname = "agent-deck";
    version = "1.16.18";
    src = agent-deck;
    vendorHash = "sha256-ZIBWsEa6IpoW66/kd40UNihBrbo5yjCsRIQatCbt4q8=";
    subPackages = [ "cmd/agent-deck" ];
    env.CGO_ENABLED = 0;
    ldflags = [
      "-s"
      "-w"
      "-X=main.Version=1.16.18"
    ];
    # The suite drives live tmux servers; the release tag already passed CI.
    doCheck = false;
    nativeBuildInputs = [ pkgs.installShellFiles ];
    postInstall = ''
      export HOME="$TMPDIR"
      installShellCompletion --cmd agent-deck \
        --zsh <("$out/bin/agent-deck" completion zsh)
    '';
    meta.mainProgram = "agent-deck";
  };

  # Dedicated Kitty window for the agent-deck TUI. The class keeps
  # run-or-raise from matching the herdr window, whose class is plain "kitty".
  kittyAgentDeck = pkgs.writeShellApplication {
    name = "kitty-agent-deck";
    text = ''
      exec ${lib.getExe config.programs.kitty.package} --class agent-deck \
        ${lib.getExe agentDeck} "$@"
    '';
  };
in
{
  # Nix owns the agent-deck version.
  home.packages = [
    agentDeck
    kittyAgentDeck # Kitty window running agent-deck (<Super>a)
    pkgs.tmux # Session backend agent-deck drives
  ];

  programs.zsh.shellAliases = {
    ad = "agent-deck"; # open the agent session dashboard
  };

  # GNOME maps the window's app id (the Kitty class) to this entry's file name
  # for its icon and title in the dash and window switcher.
  xdg.desktopEntries.agent-deck = {
    name = "Agent Deck";
    exec = "kitty-agent-deck";
    icon = "kitty";
    categories = [ "Development" ];
    settings.StartupWMClass = "agent-deck";
  };

  home.file = {
    # Declarative agent-deck config. The TUI settings panel cannot save over
    # this read-only file; change settings here instead.
    ".config/agent-deck/config.toml".text = ''
      # Managed by home-manager (agent-deck.nix).
      # Pre-select OpenCode, matching herdr's ctrl+shift+o launcher; the
      # new-session dialog still offers every installed agent.
      default_tool = "opencode"
      # Follow the desktop's light/dark preference.
      theme = "system"

      [updates]
      # Nix owns agent-deck's version; an in-place install would try to replace
      # a read-only store binary. Disable every check, prompt, and unattended path.
      check_enabled = false
      auto_update = false
      auto_install = false
      auto_restart = false
      auto_update_remotes = false
      notify_in_cli = false

      [telemetry]
      # Skip the first-run consent prompt; source builds carry no upload key.
      disabled = true

      [shell]
      # Start agents through an interactive zsh so they get the same session
      # variables and MCP tokens as a herdr pane.
      launch_shell = true

      [ui]
      # Hide picker entries for agents that are not installed.
      show_only_installed_tools = true

      [tmux]
      # Follow Kitty's background, like herdr's panel_bg = "reset".
      window_style_override = "default"
    '';
  };
}
