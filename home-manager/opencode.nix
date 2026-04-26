# opencode.nix - OpenCode AI coding assistant configuration
#
# OpenCode is a terminal-based AI coding assistant (similar to Cursor/Aider).
# This module configures:
# - Default model: Claude Opus 4.7 via GitHub Copilot
# - MCP server integration (GitHub, Terraform, Kubernetes)
# - Web UI for browser-based interaction
# - Shell aliases for quick access (o, oc, or, etc.)
# - Custom slash commands for shell history analysis and Terraform workflows
# - Specialized agents for Terraform/DevOps and code review
{ ... }:
{
  # Shell aliases for quick OpenCode invocation
  programs.zsh.shellAliases = {
    o = "opencode"; # Launch OpenCode
    oc = "opencode --continue"; # Continue previous conversation
    or = "opencode run"; # Run a command through OpenCode

    # Pre-built workflows
    osd = "opencode run '/summary daily'"; # Daily shell history summary
    osw = "opencode run '/summary weekly'"; # Weekly shell history summary
    ocm = "opencode run 'create commit and push'"; # AI-assisted commit and push
  };

  # `os`: fzf-pick one of the last 16 sessions and resume it.
  # Shows timestamp (updated time) alongside title.
  # Defined as a function (not alias) so fzf can read sessions via stdin
  # while keeping /dev/tty attached for arrow-key input.
  programs.zsh.initContent = ''
    os() {
      local sess
      sess=$(mktemp -t opencode-sess.XXXXXX) || return
      trap "rm -f -- '$sess'" EXIT INT TERM HUP
      opencode session list -n 16 --format json \
        | jq -r '.[] | "\(.id)\t\(((.updated // .created) / 1000) | strftime("%Y-%m-%d %H:%M"))\t\(.title)"' > "$sess"
      local id
      id=$(fzf --with-nth=2.. --delimiter=$'\t' < "$sess") || return
      opencode --session "''${id%%	*}"
    }
  '';

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true; # Connect to MCP servers defined in mcp.nix
    web.enable = true; # Enable browser-based web UI

    settings = {
      # Use Claude Opus 4.7 via GitHub Copilot as the default model
      model = "github-copilot/claude-opus-4.7";

      # Disable automatic update checks / version popup at startup
      autoupdate = false;

      plugin = [
        # oh-my-openagent: multi-agent harness (Sisyphus, Oracle, Atlas, …).
        # Auto-installed from npm on next opencode launch; routes agents
        # through GitHub Copilot + OpenAI fallback chains by default.
        # Docs: https://github.com/code-yeongyu/oh-my-openagent
        "oh-my-openagent@latest"

        # open-plan-annotator: intercepts plan-mode and opens a browser UI
        # for annotating/approving the agent's plan. Works with the new
        # `prometheus` planner from oh-my-openagent; on approval it hands
        # off to `sisyphus` (configured in dotfiles/open-plan-annotator.json,
        # since the upstream default of `build` is hidden by oh-my-openagent).
        # Docs: https://github.com/ndom91/open-plan-annotator
        "open-plan-annotator@latest"
      ];
    };

    # ── Global context / instructions ─────────────────────────────
    # Injected into every session as AGENTS.md-style guidance.
    # Teaches OpenCode to actively use the `memory` MCP server so
    # facts, conventions, and decisions persist across sessions.
    context = ''
      # Persistent Memory (MCP `memory` server)

      A `memory` MCP server is always available. It exposes a knowledge graph
      with entities, relations, and observations that persist across sessions
      in `~/.local/share/mcp-memory/memory.json`.

      ## When to read memory
      - At the start of any non-trivial task, call `memory.search_nodes` with
        relevant keywords (project name, repo, tool, person) before exploring
        files. If results look relevant, follow up with `memory.open_nodes`.
      - When the user references prior work ("like we did last time", "the
        usual setup", "remember that…"), query memory first.

      ## When to write memory
      Persist information that is durable and reusable across sessions:
      - Repo conventions and constraints (e.g. "nix-lifestyle: no flakes,
        signed commits required, nixfmt on touched files").
      - Architectural decisions and their rationale.
      - Stable facts about the user's environment, hosts, and tooling.
      - Recurring commands, workflows, or gotchas discovered during a task.

      Do NOT persist:
      - Secrets, tokens, credentials, or anything from `age.secrets`.
      - Ephemeral state (current branch, today's TODO, transient errors).
      - Large file contents — store a summary plus a `file_path:line` ref.

      ## How to write memory
      - Model durable nouns as entities (`create_entities`) with a clear
        `entityType` (e.g. `repo`, `host`, `tool`, `decision`, `person`).
      - Use short, atomic observations (`add_observations`); one fact each.
      - Connect entities with `create_relations` using active-voice verbs
        (`uses`, `configures`, `depends_on`, `owned_by`).
      - Prefer updating existing entities over creating duplicates; search
        first.

      ## Hygiene
      - If you notice stale or contradicted observations while reading, fix
        them with `delete_observations` and add the corrected one.
      - Keep entity names stable and unique (e.g. repo slugs, hostnames).
    '';

    # ── Custom slash commands ─────────────────────────────────────
    # These are invoked as /command-name in the OpenCode chat
    commands = {
      # /changelog: update CHANGELOG.md with new entries
      changelog = ''
        # Update Changelog Command
        Update CHANGELOG.md with new entries.
      '';
    };
  };
}
