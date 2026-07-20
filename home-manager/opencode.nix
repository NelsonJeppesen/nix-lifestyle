# opencode.nix - OpenCode AI coding assistant configuration
#
# OpenCode is a terminal-based AI coding assistant (similar to Cursor/Aider).
# This module configures:
# - Default model: Claude Opus 4.8 via GitHub Copilot
# - MCP servers declared inline. The low-risk / interactive-auth ones
#   (atlassian, github, memory) default to `enabled = true`; the rest
#   (terraform, k8s) default to `enabled = false` so they're discoverable
#   in this config but don't launch unless explicitly flipped on.
# - Web UI for browser-based interaction
# - Shell aliases for quick access (o, oc, ou) plus the `os` session picker.
#   No custom slash commands or agents are defined here — see
#   ~/.config/opencode/AGENTS.md for the global context that ships with
#   every session.
#
# This module is also imported into the NixOS `opencode` machine via the
# home-manager NixOS module (see nixos/profiles/opencode.nix), so that the
# headless `opencode serve` instance running as nelson gets the same
# settings, MCP servers, plugins, and context as the
# interactive laptop.
{
  config,
  lib,
  pkgs,
  slack-mcp-server,
  ...
}:
let
  memoryFile = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.json";
  slackMcpServer = pkgs.buildGoModule {
    pname = "slack-mcp-server";
    version = "1.3.0";
    src = slack-mcp-server;
    vendorHash = "sha256-+uQRODO9oL8mGKBmdghTxE6R9Fz+3GJFVTi17306gT8=";
    subPackages = [ "cmd/slack-mcp-server" ];
    ldflags = [
      "-s"
      "-w"
      "-X=github.com/korotovsky/slack-mcp-server/pkg/version.Version=v1.3.0"
      "-X=github.com/korotovsky/slack-mcp-server/pkg/version.BinaryName=slack-mcp-server"
    ];
    meta.mainProgram = "slack-mcp-server";
  };

  # Real NixOS hostname → short label used by Terraform for the tunnel token
  # filename + public hostname (<label>-oc.jeppesen.io). The label does NOT equal
  # the hostname — the "17" box is lg-gram-pro-17-2025. A host absent here runs
  # no tunnel.
  ocwebHostLabels = {
    "lg-gram-14-2022" = "lg-gram-14";
    "lg-gram-pro-17-2025" = "lg-gram-17";
  };
  ocwebLabelPairs = lib.concatStringsSep " " (
    lib.mapAttrsToList (host: label: "[${host}]=${label}") ocwebHostLabels
  );
in
{
  # Shell aliases for quick OpenCode invocation
  programs.zsh.shellAliases = {
    o = "opencode"; # Plugins from managed config
    oc = "opencode --continue"; # Continue previous conversation
    ou = "rm -rvf ~/.cache/opencode/node_modules ~/.cache/opencode/packages/"; # clean plugin cache
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
    enableMcpIntegration = true; # Merge programs.mcp.servers (currently none) into settings.mcp

    # Browser-based web UI, run as a systemd user service (opencode-web).
    # Pin hostname to loopback and a fixed port so the Cloudflare Tunnel
    # (terraform/core/cloudflare_tunnels.tf) has a stable upstream. The tunnel
    # + Zero Trust Access (email OTP) are the auth gate; the web UI's live
    # updates use SSE, which rides the Access cookie (no WebSocket/Access
    # conflict for the core UI). Port 4097 avoids the default 4096 used by an
    # interactive `opencode`/TUI server.
    web = {
      enable = true;
      extraArgs = [
        "--hostname"
        "127.0.0.1"
        "--port"
        "4097"
      ];
    };

    settings = {
      # Use Claude Opus 4.8 via GitHub Copilot as the default model
      model = "github-copilot/claude-opus-4.8";

      # Disable automatic update checks / version popup at startup
      autoupdate = false;

      # ── MCP servers ─────────────────────────────────────────────
      # Declared here (rather than in programs.mcp) so each server is
      # scoped to opencode and easy to flip with `enabled`. ALL default
      # to `enabled = false`; turn one on by editing this file (or
      # overlay via OPENCODE_CONFIG) and rebuilding home-manager.
      mcp = {
        # Atlassian remote MCP (Jira / Confluence Cloud). OAuth flow is
        # handled by opencode on first use — no token needs to live in
        # config or the Nix store. Enabled by default since auth is
        # interactive and harmless until the user signs in.
        atlassian = {
          type = "remote";
          url = "https://mcp.atlassian.com/v1/mcp";
          oauth = { };
          enabled = true;
        };

        # GitHub MCP server: interact with GitHub repos, PRs, issues, and actions.
        # Token sourced from $GITHUB_TOKEN (already exported by `gh auth`).
        github = {
          type = "local";
          enabled = true;
          command = [
            (lib.getExe pkgs.github-mcp-server)
            "stdio"
          ];
          environment = {
            GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_TOKEN}";
          };
        };

        # Terraform MCP server: search modules, providers, and registry docs.
        terraform = {
          type = "local";
          enabled = true;
          command = [
            (lib.getExe pkgs.terraform-mcp-server)
            "stdio"
          ];
        };

        # Kubernetes MCP server: query cluster resources, pods, logs, etc.
        k8s = {
          type = "local";
          enabled = false;
          command = [ (lib.getExe pkgs.mcp-k8s-go) ];
        };

        # Memory MCP server: persistent knowledge graph memory across sessions.
        # MEMORY_FILE_PATH pins storage to a stable XDG-style location so the
        # graph survives package updates and is easy to back up.
        memory = {
          type = "local";
          enabled = true;
          command = [ (lib.getExe pkgs.mcp-server-memory) ];
          environment = {
            MEMORY_FILE_PATH = memoryFile;
          };
        };

        # Slack workspace search, channel history, threads, DMs, and unread
        # messages. Keep an explicit read-only tool allowlist because upstream
        # enables some workspace-mutating user-group tools by default. Stealth
        # mode uses the browser session token and cookie from the environment.
        slack = {
          type = "local";
          enabled = false;
          command = [ (lib.getExe slackMcpServer) ];
          environment = {
            SLACK_MCP_ENABLED_TOOLS = "conversations_history,conversations_replies,conversations_search_messages,conversations_unreads,channels_list,channels_me,usergroups_list,users_search";
            SLACK_MCP_XOXC_TOKEN = "{env:SLACK_MCP_XOXC_TOKEN}";
            SLACK_MCP_XOXD_TOKEN = "{env:SLACK_MCP_XOXD_TOKEN}";
          };
        };

        # Read/write Slack: same server as `slack` above, but with the
        # workspace-mutating tools added to the allowlist. Listing a write tool
        # in SLACK_MCP_ENABLED_TOOLS registers it without channel restrictions,
        # so conversations_add_message, reactions_add/remove, and
        # conversations_mark are all live here. Disabled by default; enable
        # deliberately when a task needs to post/react/mark. Stealth mode uses
        # the browser session token and cookie from the environment.
        slack-write = {
          type = "local";
          enabled = false;
          command = [ (lib.getExe slackMcpServer) ];
          environment = {
            SLACK_MCP_ENABLED_TOOLS = "conversations_history,conversations_replies,conversations_search_messages,conversations_unreads,channels_list,channels_me,usergroups_list,users_search,conversations_add_message,reactions_add,reactions_remove,conversations_mark";
            SLACK_MCP_XOXC_TOKEN = "{env:SLACK_MCP_XOXC_TOKEN}";
            SLACK_MCP_XOXD_TOKEN = "{env:SLACK_MCP_XOXD_TOKEN}";
          };
        };
      };

      plugin = [
        # open-plan-annotator: intercepts plan-mode and opens a browser UI
        # for annotating/approving the agent's plan.
        # Docs: https://github.com/ndom91/open-plan-annotator
        # "open-plan-annotator@latest"

        # open-conclave: multi-agent debate orchestrator. Adds a Conclave
        # agent that runs parallel sub-agents (Harper/Benjamin/Lucas),
        # moderated by a Captain with early stopping on consensus.
        # Docs: https://github.com/martinzokov/open-conclave
        "open-conclave@latest"

        # opencode-handoff: /handoff command that distills the current
        # conversation into a focused continuation prompt and opens it in a
        # fresh session; adds a read_session tool for prior transcripts.
        # Docs: https://github.com/joshuadavidthomas/opencode-handoff
        "opencode-handoff@latest"

        # opencode-autotitle: AI-powered automatic session naming. Sets an
        # instant keyword title on the first message, then refines it with a
        # cheap model once the response lands. Never overwrites custom titles.
        # Docs: https://github.com/pawelma/opencode-autotitle
        # "opencode-autotitle@latest" # "open-trees@latest"
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

      # Interactive & long-running commands (herdr tabs)

      The `bash` tool has no TTY: any command that prompts for input, waits on
      a TTY, or runs as a long-lived foreground process will silently block or
      fail there. Instead, run such commands in a dedicated herdr tab. herdr
      is the terminal multiplexer this session runs inside; the `herdr` CLI
      talks to it over a local socket. Full command reference: the `herdr`
      skill (auto-loaded when `HERDR_ENV=1`), or `herdr <group> --help`.

      Do NOT split panes to run things. Always create a new named tab instead,
      with its label prefixed by `oc: ` (e.g. `oc: terraform apply`,
      `oc: dev server`) so the tab is clearly attributable to this session.
      If you do split a pane, always split horizontally (top to bottom,
      `--direction down`), never vertically (side by side).

      Precondition: only usable when `HERDR_ENV=1` (i.e. running inside herdr).
      If it is not set, say so and ask the user to run the command themselves —
      do NOT fall back to the `bash` tool for anything interactive.

      ## Run in a herdr tab (NOT the bash tool)
      - `sudo` (password prompt) and anything that may escalate
      - `terraform init` / `plan` / `apply` / `destroy` (provider auth,
        approval prompts, workspace selection, `-var` prompts)
      - `aws sso login`, `aws configure sso`, `gcloud auth login`,
        `az login`, `vault login`, `op signin` — any browser/device-code
        or interactive auth flow
      - `direnv allow` when it triggers a nested auth/login
      - `ssh` to a host that may prompt for a passphrase, host-key
        confirmation, or 2FA
      - `git push` / `pull` against a remote that may prompt for a
        passphrase or credential helper
      - `nh os switch` / `nh home switch` / `nixos-rebuild switch`
        (sudo + long-running TUI diff output)
      - `npm login`, `gh auth login`, `docker login`, `helm registry login`
      - long-lived servers, log watchers, and test runners you want to read
        from later, and REPLs (`psql`, `redis-cli`, `nix repl`, `tf console`,
        `kubectl exec -it`)

      ## How
      - Create a named tab with `herdr tab create --workspace <id> --label
        "oc: <short desc>" --no-focus`, then parse the tab's root pane id from
        `result.root_pane`. Run the command in that pane with `herdr pane run
        <root_pane> "<command>"`. Get the current workspace id from `herdr
        workspace list` (or read your own pane's ids from `herdr pane list`).
      - Read progress with `herdr pane read <root_pane> --source
        recent-unwrapped`; block on completion with `herdr wait output
        <root_pane> --match "<sentinel>"` (append `&& echo __DONE__` to the
        command and match that). `wait output` returns the transcript in its
        own payload — read from that, or settle briefly before a separate
        `pane read`.
      - For SECRETS / AUTH (passwords, 2FA, SSO device codes): do NOT type them
        yourself and do NOT `pane send-text` credentials. Surface the auth
        URL / device code / prompt to the user verbatim, focus the tab
        (`herdr tab focus <tab_id>` / tell them which tab), and wait for them
        to complete it. The human owns credential entry.
      - For non-interactive, short-lived commands (ls, grep, nixfmt, git
        status, etc.) keep using the `bash` tool — a herdr tab is overhead.
      - If unsure whether a command will prompt, prefer a herdr tab.
    '';

  };

  # herdr agent skill: teaches opencode to DRIVE herdr over its local socket
  # (split panes, spawn sibling agents, read output, wait on state) when it is
  # running inside a herdr-managed pane. opencode auto-loads any
  # skills/<name>/SKILL.md from its global config dir; the frontmatter
  # `description` gates activation. Vendored verbatim from
  # github.com/ogulcancelik/herdr//SKILL.md so it is Nix-managed and pinned,
  # rather than fetched imperatively via `npx skills add`.
  #
  # Safe on the headless `opencode serve` machine too: the skill's own first
  # rule is to stop unless HERDR_ENV=1, which that server never sets, so it
  # simply stays dormant there.
  home.file.".config/opencode/skills/herdr/SKILL.md".source = ./dotfiles/herdr-skill.md;

  # Ensure the memory file's parent directory exists before the memory
  # MCP server is invoked; mcp-server-memory will create the JSON file
  # itself. Cheap to keep even when the server is disabled.
  home.activation.mcpMemoryDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p "${builtins.dirOf memoryFile}"
  '';

  # Install MCP server binaries into the environment so they can be invoked
  # directly from the shell — and so the `command` paths above resolve even
  # when an MCP server is toggled `enabled = true`.
  home.packages = [
    pkgs.github-mcp-server
    pkgs.mcp-grafana # Grafana MCP server (for dashboard/alert queries) — no opencode entry yet
    pkgs.mcp-k8s-go
    pkgs.mcp-server-memory
    pkgs.terraform-mcp-server
    slackMcpServer
  ];

  # Cloudflare Tunnel connector for the opencode web UI. Terraform owns the
  # tunnel, its DNS (<label>-oc.jeppesen.io), and the Zero Trust Access app
  # (email OTP). This unit runs cloudflared with the per-host connector token,
  # forwarding the public hostname to the local opencode-web service (port 4097,
  # set in programs.opencode.web above). The web UI uses SSE, which rides the
  # Access cookie — no WebSocket/Access conflict for the core UI.
  #
  # Token files decrypt only on their own host (see home.nix age.secrets, named
  # by short label). ExecStart maps the real hostname to its label; a host with
  # no tunnel exits cleanly.
  systemd.user.services.opencode-web-tunnel = {
    Unit = {
      Description = "Cloudflare Tunnel for the opencode web UI";
      After = [
        "network-online.target"
        "opencode-web.service"
      ];
      Wants = [
        "network-online.target"
        "opencode-web.service"
      ];
    };

    Service =
      let
        tokenDir = "${config.home.homeDirectory}/.config/opencode-web/cloudflared";
        run = pkgs.writeShellApplication {
          name = "opencode-web-tunnel-run";
          runtimeInputs = [ pkgs.cloudflared ];
          text = ''
            declare -A labels=(${ocwebLabelPairs})
            host="$(hostname)"
            label="''${labels[$host]:-}"
            if [ -z "$label" ]; then
              echo "opencode-web-tunnel: host '$host' runs no tunnel; nothing to do." >&2
              exit 0
            fi
            token_file="${tokenDir}/token.$label"
            if [ ! -r "$token_file" ]; then
              echo "opencode-web-tunnel: token for '$label' missing at $token_file." >&2
              exit 1
            fi
            exec cloudflared tunnel --no-autoupdate run --token "$(cat "$token_file")"
          '';
        };
      in
      {
        ExecStart = lib.getExe run;
        Restart = "on-failure";
        RestartSec = 5;
      };

    Install.WantedBy = [ "default.target" ];
  };
}
