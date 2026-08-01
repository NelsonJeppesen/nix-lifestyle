# pi.nix - Pi coding agent configuration
#
# Pi is installed alongside OpenCode for early testing. The herdr skill lets
# Pi control tabs and panes when it is running inside a herdr session; herdr's
# Pi integration reports agent state in the sidebar. MCP support is supplied
# by a pinned, Nix-built extension rather than `pi install`.
{
  config,
  lib,
  pkgs,
  pi-mcp-adapter,
  slack-mcp-server,
  ...
}:
let
  piMcpAdapter = pkgs.buildNpmPackage {
    pname = "pi-mcp-adapter";
    version = "2.11.0";
    src = pi-mcp-adapter;
    # Upstream's lock file omits integrity on three nested dev-dependency
    # entries. Supply the published npm integrities so Nix's dependency
    # prefetcher can validate the complete lock file.
    postPatch = ''
      ${lib.getExe pkgs.jq} '
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-XKxgdjhcPuyjrthCOFSgfzT3xZ1uBrJ1IMVDxci1to6hIN6BIg9J5iY8q0pGXK1DLgATLP23da+1UyZLwA360Q==" |
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-ai"].integrity = "sha512-9jR23tOl0BIUdQMn70Gr72xYBpM7Xgl9Lyv7gAnU1USfkNRuYG/f/edLl+n/Dp/RafDW3JI4DF7y/GhgkORuew==" |
        .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui"].integrity = "sha512-FUVOjDn1DVwM1uHD5MNYboXQrXjIDbSt+BQ3py7nQWCY62tKfxgiM1OBMxTcwRWLfSdZHUPpV0hm1loIdUJnPw=="
      ' package-lock.json > package-lock.json.tmp
      mv package-lock.json.tmp package-lock.json
    '';
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-uyQvySvDYGUb1ukZuHsFQIb5+eRJGg9snOuXew3bRdg=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R . "$out/"
      runHook postInstall
    '';
  };

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
in
{
  home.packages = [ pkgs.pi-coding-agent ];

  programs.zsh.shellAliases = {
    p = "pi";
    pc = "pi --continue";
  };

  home.file = {
    # Share the same Agent Skills-compatible herdr instructions as OpenCode.
    ".pi/agent/skills/herdr/SKILL.md".source = ./dotfiles/herdr-skill.md;

    # Pi discovers one directory deep under extensions. Keeping the complete
    # npm package together lets its TypeScript entrypoint resolve the Nix-built
    # node_modules without any mutable package installation under ~/.pi.
    ".pi/agent/extensions/mcp-adapter".source = piMcpAdapter;

    # Mirror OpenCode's enabled MCP servers, plus its read-only Slack server
    # requested for Pi testing. OpenCode's disabled k8s and mutating
    # slack-write servers remain disabled here as well.
    ".pi/agent/mcp.json".text = builtins.toJSON {
      settings = {
        toolPrefix = "server";
        idleTimeout = 10;
        outputGuard = true;
      };
      mcpServers = {
        atlassian = {
          url = "https://mcp.atlassian.com/v1/mcp";
          auth = "oauth";
          oauth = { };
          lifecycle = "lazy";
        };
        github = {
          command = lib.getExe pkgs.github-mcp-server;
          args = [ "stdio" ];
          env.GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_TOKEN}";
          lifecycle = "lazy";
        };
        terraform = {
          command = lib.getExe pkgs.terraform-mcp-server;
          args = [ "stdio" ];
          lifecycle = "lazy";
        };
        memory = {
          command = lib.getExe pkgs.mcp-server-memory;
          env.MEMORY_FILE_PATH = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.json";
          lifecycle = "lazy";
        };
        slack = {
          command = lib.getExe slackMcpServer;
          env = {
            SLACK_MCP_ENABLED_TOOLS = "conversations_history,conversations_replies,conversations_search_messages,conversations_unreads,channels_list,channels_me,usergroups_list,users_search";
            SLACK_MCP_XOXC_TOKEN = "\${SLACK_MCP_XOXC_TOKEN}";
            SLACK_MCP_XOXD_TOKEN = "\${SLACK_MCP_XOXD_TOKEN}";
          };
          lifecycle = "lazy";
        };
      };
    };
  };

  # Keep the generated herdr extension matched to the installed herdr version.
  # It reports Pi's blocked / working / done state to herdr's sidebar.
  home.activation.herdrPiIntegration = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD ${lib.getExe pkgs.herdr} integration install pi || true
  '';
}
