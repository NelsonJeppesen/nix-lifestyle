{
  config,
  lib,
  pkgs,
  herdr-plus,
  ...
}:
let
  # Upstream's build step runs `go build` or downloads a release binary into its
  # own checkout; build the pinned tag instead and lay the result out as a
  # plugin root: herdr-plugin.toml beside bin/herdr-plus, which the manifest's
  # entry points invoke by that relative path.
  herdrPlus = pkgs.buildGoModule {
    pname = "herdr-plus";
    inherit ((lib.importTOML "${herdr-plus}/herdr-plugin.toml")) version;
    src = herdr-plus;
    vendorHash = "sha256-im2gPhLarMf1w/8rhxbOe9EhUdvseffukT9tqU4EEXI=";

    subPackages = [ "." ];
    # The suite shells out to git to tell work trees from plain folders.
    nativeCheckInputs = [ pkgs.git ];
    ldflags = [
      "-s"
      "-w"
    ];

    postInstall = ''
      root=$out/share/herdr-plus
      mkdir -p $root/bin
      mv $out/bin/herdr-plus $root/bin/
      ln -s $root/bin/herdr-plus $out/bin/herdr-plus
      cp herdr-plugin.toml $root/
    '';

    meta.mainProgram = "herdr-plus";
  };

  pluginId = "cloudmanic.herdr-plus";
  pluginRoot = "${herdrPlus}/share/herdr-plus";
  configDir = ".config/herdr/plugins/config/${pluginId}";
  devops = "${config.home.homeDirectory}/source/devops";

  # Herdr records a linked plugin's resolved root, so relink whenever the store
  # path changes, keeping a disabled plugin disabled.
  ensurePlugin = pkgs.writeShellApplication {
    name = "herdr-plus-ensure";
    runtimeInputs = [
      pkgs.herdr
      pkgs.jq
    ];
    text = ''
      registration="$(herdr plugin list --plugin ${pluginId} --json \
        | jq -c '.result.plugins[0] // empty')"
      if [ "$(jq -r '.plugin_root // empty' <<<"$registration")" != "${pluginRoot}" ]; then
        state=--enabled
        if jq -e '.enabled == false' <<<"$registration" >/dev/null; then
          state=--disabled
        fi
        herdr plugin link "${pluginRoot}" "$state" >/dev/null
      fi
    '';
  };

  # ARC worktrees of the devops repo, each in its own Space running an agent;
  # Jira calls (file, list, close tickets) go through Claude Code's Atlassian MCP.
  herdrArc = pkgs.writeShellApplication {
    name = "herdr-arc";
    runtimeInputs = [
      config.programs.claude-code.finalPackage
      config.programs.mise.package
      pkgs.git
      pkgs.herdr
      pkgs.jq
    ];
    text = ''
      ATLASSIAN_MCP_URL=${config.programs.mcp.servers.atlassian.url}
    ''
    + builtins.readFile ./bin/herdr-arc;
  };

  toml = pkgs.formats.toml { };

  # One project template per workspace shape; see upstream README "Projects".
  projects = {
    devops = {
      name = "DevOps";
      group = "Work";
      description = "Alchemer devops monorepo: agent, shell, and git";
      working_dir = devops;
      tabs = [
        {
          name = "claude";
          command = "claude";
        }
        {
          name = "shell";
          panes = [
            { command = "git status --short --branch"; }
            {
              label = "worktrees";
              command = "git worktree list";
              split = "right";
              ratio = 0.4;
            }
          ];
        }
      ];
    };

    devops-terraform = {
      name = "DevOps: Terraform";
      group = "Work";
      description = "apptentive/terraform checkout inside devops; plan/apply need its review gates";
      working_dir = "${devops}/terraform";
      tabs = [
        {
          name = "claude";
          command = "claude";
        }
        { name = "shell"; }
      ];
    };

    nix-lifestyle = {
      name = "nix-lifestyle";
      group = "Personal";
      description = "NixOS + Home Manager flakes";
      working_dir = "${config.home.homeDirectory}/source/personal/nix-lifestyle";
      tabs = [
        {
          name = "claude";
          command = "claude";
        }
        { name = "shell"; }
      ];
    };
  };

  # Only the ARC worktree flow; herdr-plus appends the typed or picked value as
  # one shell-quoted argument whenever a command never mentions .Value.
  quickActions = {
    arc-new = {
      name = "ARC: New ticket + worktree";
      description = "Claude Code files an ARC Task, then a Space branches it from origin/main";
      type = "form";
      command = "${lib.getExe herdrArc} new ${devops}";
      form.prompt = "Ticket title";
    };

    arc-ticket = {
      name = "ARC: Worktree for my open ticket";
      description = "Pick an open ARC ticket assigned to you; an existing branch just opens";
      type = "select";
      options_command = "${lib.getExe herdrArc} tickets ${devops}";
      command = "${lib.getExe herdrArc} key ${devops}";
    };

    arc-open = {
      name = "ARC: Open worktree";
      description = "Focus its Space, reopen its worktree, or check it out from origin";
      type = "select";
      options_command = "${lib.getExe herdrArc} list ${devops}";
      command = "${lib.getExe herdrArc} open ${devops}";
    };

    arc-close = {
      name = "ARC: Close worktree + ticket";
      description = "Remove a clean checkout, close its Space, and mark the ticket Done";
      type = "select";
      options_command = "${lib.getExe herdrArc} list ${devops} worktrees";
      command = "${lib.getExe herdrArc} close ${devops}";
    };
  };
in
{
  home.packages = [ herdrPlus ];

  home.file = {
    # herdr-plus reads its config from the herdr-managed plugin config dir.
    # Because quick-actions/ already exists, it never seeds upstream's examples.
    "${configDir}/config.toml".source = toml.generate "herdr-plus-config.toml" {
      projects.placement = "zoomed";
      quick_actions.placement = "popup";
    };
  }
  // lib.mapAttrs' (
    slug: project:
    lib.nameValuePair "${configDir}/projects/${slug}.toml" {
      source = toml.generate "herdr-plus-project-${slug}.toml" project;
    }
  ) projects
  // lib.mapAttrs' (
    slug: action:
    lib.nameValuePair "${configDir}/quick-actions/${slug}.toml" {
      source = toml.generate "herdr-plus-action-${slug}.toml" action;
    }
  ) quickActions;

  home.activation.herdrPlus = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ! $DRY_RUN_CMD ${lib.getExe ensurePlugin}; then
      warnEcho "herdr-plus setup failed; retry with ${lib.getExe ensurePlugin}, then check 'herdr plugin list'."
    fi
  '';
}
