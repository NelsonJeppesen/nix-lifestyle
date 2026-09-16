{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Hostnames to tunnel labels.
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
    enableMcpIntegration = true; # Pull the shared programs.mcp.servers catalogue (mcp.nix) into settings.mcp

    # Loopback web UI behind Cloudflare Access.
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
      # Use GPT-5.6 Sol via GitHub Copilot as the default model
      model = "github-copilot/gpt-5.6-sol";

      # Disable automatic update checks / version popup at startup
      autoupdate = false;

      # Trusted external directories.
      permission = {
        external_directory = {
          "~/source/**" = "allow";
          "~/tmp/**" = "allow";
        };
      };

      plugin = [
        # Browser plan review.
        # "open-plan-annotator@latest"
        # Agent debate.
        # "open-conclave@latest"
        # Session handoff plugin.
        # "opencode-handoff@latest"
        # Session titles.
        # "opencode-autotitle@latest" # "open-trees@latest"
      ];
    };

    # Agent instructions.
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

      ${builtins.readFile ../doc/herdr-policy.md}

      # Modern CLI toolbox

      Prefer the dedicated OpenCode file tools for ordinary reads, searches,
      and edits. When shell execution or a pipeline is the better fit, favor
      these installed tools over their older equivalents:

      - `rg` instead of `grep` for content search and match counting.
      - `ast-grep` for syntax-aware search and rewriting when a text match
        would also catch comments, strings, or unrelated syntax.
      - `fd` instead of `find` for filesystem discovery.
      - `bat --plain --paging=never` instead of `cat` for readable terminal
        output; do not invoke an interactive pager from the `bash` tool.
      - `fzf` for interactive selection, only in a user-facing herdr tab.
      - `jq`/`jqp` for JSON; `yq`, `yj`, and `dasel` for structured data;
        `fastgron` when flattening JSON makes text search clearer.
      - `choose` instead of complex `cut` invocations.
      - `z` (Zoxide) for interactive directory jumps in a persistent shell;
        use explicit paths in scripts and tool calls.
      - `gh` for GitHub operations, `nh` for Nix/Home Manager workflows, and
        `herdr` for terminal orchestration.
      - `hurl` for repeatable HTTP request tests; keep `curl` for ad hoc HTTP.

      Also available where relevant: `kubectl`, `k9s`, `kubectx`, `helm`,
      `helmfile`, `stern`, `kubeconform`, `aws`, `vault`, `sops`, `shellcheck`,
      `shfmt`, `actionlint`, `hadolint`, `yamllint`, and `markdownlint`.

      Use modern tools when they make a command clearer or safer, not merely
      to replace a simple dedicated OpenCode tool call.
    '';

  };

  # Run the tunnel with the matching host token.
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
