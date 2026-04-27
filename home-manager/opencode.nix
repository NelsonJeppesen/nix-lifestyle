# opencode.nix - OpenCode AI coding assistant configuration
#
# OpenCode is a terminal-based AI coding assistant (similar to Cursor/Aider).
# This module configures:
# - Default model: Claude Opus 4.7 via GitHub Copilot
# - MCP servers declared inline. A few low-risk / interactive-auth ones
#   (atlassian, github, memory) default to `enabled = true`; the rest
#   default to `enabled = false` so they're discoverable in this config
#   but don't launch (or hit AWS) unless explicitly flipped on.
# - Web UI for browser-based interaction
# - Shell aliases for quick access (o, oc, or, etc.)
# - Custom slash commands (changelog, commit-and-push, update-pr-desc).
#   No custom agents are defined here yet — see ~/.config/opencode/AGENTS.md
#   for the global context that ships with every session.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # oh-my-openagent is opt-in: kept out of the managed opencode.json so the
  # default `opencode` (and `op`) launches without it. The `omo` alias layers
  # it back in via OPENCODE_CONFIG -> opencode.with-omo.json. We can't go the
  # other way (subtract via OPENCODE_CONFIG) because opencode MERGES configs
  # rather than replacing them, so a filtered-down override cannot remove a
  # plugin that the global config already declared.
  opencodeWithOmoSettings = {
    plugin = [ "oh-my-openagent@latest" ];
  };

  memoryFile = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.json";

  # Helper for awslabs/mcp servers launched via `uv tool run` against PyPI.
  # All such servers ship as `awslabs.<name>-mcp-server` on PyPI; we pin to
  # @latest because uv caches resolved versions per-machine, so this is
  # reproducible per-tool-cache, not per-eval. Default environment sets
  # FASTMCP_LOG_LEVEL=ERROR to silence the framework's chatty INFO logs that
  # would otherwise interleave with MCP stdio traffic; per-server `env`
  # entries are merged on top.
  mkAwslabsMcp =
    {
      name, # e.g. "cloudtrail" -> awslabs.cloudtrail-mcp-server
      extraArgs ? [ ], # appended after the package spec (e.g. [ "--readonly" ])
      env ? { }, # merged on top of the default environment
      enabled ? false,
    }:
    {
      type = "local";
      inherit enabled;
      command = [
        (lib.getExe pkgs.uv)
        "tool"
        "run"
        "awslabs.${name}-mcp-server@latest"
      ]
      ++ extraArgs;
      environment = {
        FASTMCP_LOG_LEVEL = "ERROR";
      }
      // env;
    };
in
{
  # Shell aliases for quick OpenCode invocation
  programs.zsh.shellAliases = {
    omo = "OPENCODE_CONFIG=${config.xdg.configHome}/opencode/opencode.with-omo.json opencode"; # Layer oh-my-openagent on top of the managed config
    o = "opencode"; # Plugins from managed config (currently: everything except oh-my-openagent)
    op = "opencode --pure"; # Launch vanilla OpenCode (no plugins)

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
    enableMcpIntegration = true; # Merge programs.mcp.servers (currently none) into settings.mcp
    web.enable = true; # Enable browser-based web UI

    settings = {
      # Use Claude Opus 4.7 via GitHub Copilot as the default model
      model = "github-copilot/claude-opus-4.7";

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
          enabled = false;
          command = [
            (lib.getExe pkgs.terraform-mcp-server)
            "stdio"
          ];
        };

        # AWS API MCP server (awslabs/mcp): exposes the full AWS CLI surface to
        # the agent via two tools — `call_aws` (validated AWS CLI execution) and
        # `suggest_aws_commands` (natural-language → CLI suggestions, including
        # APIs released after the model's knowledge cutoff).
        #
        # Not in nixpkgs; upstream ships as a Python package on PyPI. We invoke
        # it through `uvx` (provided by pkgs.uv) which downloads + caches the
        # latest version on first use, mirroring upstream's recommended install.
        #
        # Safety posture (deliberate):
        #   - READ_OPERATIONS_ONLY=true  — server refuses any non-read API call,
        #     regardless of IAM. Mutations go through the regular `aws` CLI in a
        #     PTY so they remain explicit and visible.
        #   - AWS_REGION / AWS_PROFILE are NOT pinned here; they're inherited
        #     from the shell (typically set per-project via direnv `.envrc`),
        #     so the agent operates against whatever account/region the user is
        #     currently in.
        "[aws] api" = mkAwslabsMcp {
          name = "aws-api";
          env = {
            READ_OPERATIONS_ONLY = "true";
          };
        };

        # CloudTrail MCP server (awslabs/mcp): query CloudTrail event history,
        # CloudTrail Lake, and Insights. Read-only by nature of the CloudTrail
        # API surface (LookupEvents, StartQuery, GetQueryResults, etc.), so no
        # extra safety env-var is needed beyond IAM scoping.
        #
        # Same launch pattern as aws-api: `uv tool run` against PyPI; AWS_PROFILE
        # / AWS_REGION inherited from the shell (direnv per-project), NOT pinned
        # here. Upstream sample config pins AWS_PROFILE — we deliberately don't,
        # so the same MCP works across every project's profile.
        #
        # FASTMCP_LOG_LEVEL=ERROR silences the framework's chatty INFO logs that
        # would otherwise interleave with MCP stdio traffic.
        "[aws] cloudtrail" = mkAwslabsMcp { name = "cloudtrail"; };

        # CloudWatch MCP server (awslabs/mcp): query CloudWatch logs, metrics,
        # and alarms. Read-only by virtue of the underlying API surface
        # (FilterLogEvents, GetMetricData, DescribeAlarms, …); IAM is the
        # ultimate gate. AWS_PROFILE / AWS_REGION inherited from the shell.
        "[aws] cloudwatch" = mkAwslabsMcp { name = "cloudwatch"; };

        # IAM MCP server (awslabs/mcp): inspect users, roles, policies,
        # attachments, and simulate policy evaluations.
        #
        # `--readonly` is REQUIRED here — the server otherwise exposes
        # mutating tools (create/delete/attach/detach). Mutations to IAM
        # should always go through the regular `aws` CLI in a PTY so they
        # remain explicit and auditable.
        "[aws] iam" = mkAwslabsMcp {
          name = "iam";
          extraArgs = [ "--readonly" ];
        };

        # EKS MCP server (awslabs/mcp): query clusters, nodegroups, addons,
        # workloads, and events. Wraps `eksctl` / EKS API / kubectl-style
        # introspection.
        #
        # Safety: DO NOT add `--allow-write` or `--allow-sensitive-data-access`
        # to the command array. Those flags unlock cluster mutations and Secret
        # contents respectively; both should go through `kubectl` / `eksctl`
        # in a PTY so they stay explicit. AWS_PROFILE / AWS_REGION inherited
        # from the shell; KUBECONFIG falls through to the default ~/.kube/config.
        "[aws] eks" = mkAwslabsMcp { name = "eks"; };

        # AWS Network MCP server (awslabs/mcp): inspect VPCs, subnets, route
        # tables, security groups, NACLs, TGWs, etc. Read-only by API surface;
        # useful for connectivity debugging without leaving the chat.
        "[aws] network" = mkAwslabsMcp { name = "aws-network"; };

        # AWS Documentation MCP server (awslabs/mcp): search and fetch official
        # AWS docs (service docs, API references, CLI references). No AWS creds
        # required — pure documentation retrieval. AWS_DOCUMENTATION_PARTITION
        # selects the doc set (`aws` for commercial, `aws-cn` / `aws-us-gov`
        # for the partitioned regions).
        "[aws] documentation" = mkAwslabsMcp {
          name = "aws-documentation";
          env = {
            AWS_DOCUMENTATION_PARTITION = "aws";
          };
        };

        # AWS Pricing MCP server (awslabs/mcp): query the public AWS Pricing
        # API for on-demand / reserved / savings-plan pricing. Useful for
        # cost-estimating Terraform changes before merging. Read-only.
        "[aws] pricing" = mkAwslabsMcp { name = "aws-pricing"; };

        # Billing & Cost Management MCP server (awslabs/mcp): query Cost
        # Explorer, budgets, anomalies, Savings Plans, and Storage Lens.
        # Read-only against the billing APIs; requires the active profile to
        # have ce:* / budgets:* / cur:* permissions on the payer account.
        #
        # Known issue: awslabs/mcp#3258 — dynamic AWS_PROFILE selection can be
        # flaky; if you hit auth errors, set AWS_PROFILE explicitly in the
        # shell that launches opencode rather than relying on direnv handover.
        "[aws] billing-cost-management" = mkAwslabsMcp { name = "billing-cost-management"; };

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
      };

      plugin = [
        # NOTE: oh-my-openagent is intentionally NOT listed here. It's opt-in
        # via the `omo` alias, which layers it back in through OPENCODE_CONFIG.
        # See opencode.with-omo.json at the bottom of this file. Reason: opencode
        # merges configs rather than replacing them, so once omo is in the
        # global config nothing can remove it for a single launch.
        # Docs: https://github.com/code-yeongyu/oh-my-openagent

        # open-plan-annotator: intercepts plan-mode and opens a browser UI
        # for annotating/approving the agent's plan. Works with the new
        # `prometheus` planner from oh-my-openagent; on approval it hands
        # off to `sisyphus` (configured in dotfiles/open-plan-annotator.json,
        # since the upstream default of `build` is hidden by oh-my-openagent).
        # Docs: https://github.com/ndom91/open-plan-annotator
        "open-plan-annotator@latest"

        # OpenCode plugin for interactive PTY management - run background
        # processes, send input, read output with regex filtering
        "opencode-pty@latest"

        # An Opencode plugin for managing git worktrees
        "open-trees@latest"
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

      # Interactive Commands (MCP `pty` server / opencode-pty)

      The `opencode-pty` plugin (https://github.com/shekohex/opencode-pty)
      exposes a background PTY manager. Use it — NOT the `bash` tool — for
      any command that may prompt for user input, hang waiting on a TTY, or
      run as a long-lived foreground process. The `bash` tool has no TTY
      and will silently block or fail on prompts.

      ## Always use PTY for
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
      - REPLs and watchers the user explicitly wants to interact with
        (`psql`, `redis-cli`, `nix repl`, `tf console`, `kubectl exec -it`)

      ## How
      - Start the process via the pty MCP tool, capture its session id, then
        read output and send input as needed. Surface auth URLs / device
        codes to the user verbatim and wait for them to complete the action.
      - For non-interactive, short-lived commands (ls, grep, nixfmt, git
        status, etc.) keep using the `bash` tool — PTY is overhead.
      - If unsure whether a command will prompt, prefer PTY.
    '';

    # ── Custom slash commands ─────────────────────────────────────
    # These are invoked as /command-name in the OpenCode chat
    commands = {
      # /changelog: generate release notes from commits since the last tag
      #             and write them into CHANGELOG.md (Keep-a-Changelog style).
      changelog = builtins.readFile ./opencode/commands/changelog.md;

      # /commit-and-push: stage, commit, and push current changes
      commit-and-push = builtins.readFile ./opencode/commands/commit-and-push.md;

      # /update-pr-desc: refresh the current PR's description from commits
      update-pr-desc = builtins.readFile ./opencode/commands/update-pr-desc.md;
    };
  };

  # Overlay config: merged ON TOP of the managed opencode.json by setting
  # OPENCODE_CONFIG. Adds oh-my-openagent to the plugin list. Selected via
  # the `omo` alias above.
  xdg.configFile."opencode/opencode.with-omo.json".text = builtins.toJSON opencodeWithOmoSettings;

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
    pkgs.uv # provides `uv tool run` used to launch awslabs.* MCP servers
  ];
}
