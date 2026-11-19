# Configure Pi extensions, lazy MCP connections, and Herdr lifecycle integration.
{
  config,
  lib,
  pkgs,
  pi-mcp-adapter,
  ...
}:
let
  # Upstream's lock file omits integrity on these nested dev-dependency
  # entries (all version 1.0.0 under pi-coding-agent/node_modules). Values are
  # the registry's dist.integrity for each tarball.
  missingIntegrity = {
    "@earendil-works/chord" =
      "sha512-BIfWfrByM0pKq6tfKYXuwx0ed2CvaqIM3EDA7Dps+fP+d3CiPWdlHi1cDsJC05llqKJoRz5//G0hz0yQwwjISQ==";
    "@earendil-works/pi-agent-core" =
      "sha512-bHFONjtEBDqiV+g1DmmtkSlfAaqHELr+XO+6I5Nah4gswwZrLJO4yZB/JjsnlI4AKWTayBLfgS6DCbeBBz9e2Q==";
    "@earendil-works/pi-ai" =
      "sha512-3/W1vdDaVtpeMd23ElvJC12HLA5yS/BGqqcXF+0SK082dN7cbgNcCwguTBRBC258Ke8SzSvUW1B75iAf8w8IxA==";
    "@earendil-works/pi-codemode" =
      "sha512-LPpFI4+T9NzDnhBDs15izWAolaoM8xnwqdziRd6Zx8BQeoEPvzefD2vMMzSyF0rOtq34TfQqkZ0ki16f6cGdMg==";
    "@earendil-works/pi-mcp" =
      "sha512-rYra0aF5iPmJd+fsB+VBuqxWNABGJ3Iiyhg0CqIc/91ta2n7IvQmCp0Cac/YkUTNnvRsVZnjgAiBkRi6+ouWuw==";
    "@earendil-works/pi-telemetry" =
      "sha512-WjNBj5TYIiPZFQEz2WlULcDwPLaKwIlmsKjVeYM+LJSbnSp38kWsHUJysIDGnu23IcLbKoPtywsvYfUJCeZePA==";
    "@earendil-works/pi-tui" =
      "sha512-JsT7kXnpZA2YOtQu6RyriyxEO0eJIzPyfiH09bH+OLN5+s18HYkwaUD/tBkjhnSfMu6/50CQPRYJagzSP6HdPw==";
  };

  piMcpAdapter = pkgs.buildNpmPackage {
    pname = "pi-mcp-adapter";
    version = "7.0.1";
    src = pi-mcp-adapter;
    # A missing entry fails the build instead of adding a stray lock entry.
    postPatch = ''
      ${lib.getExe pkgs.jq} --argjson integrity ${lib.escapeShellArg (builtins.toJSON missingIntegrity)} '
        reduce ($integrity | to_entries[]) as $e (.;
          ("node_modules/@earendil-works/pi-coding-agent/node_modules/" + $e.key) as $path
          | if .packages[$path] == null then error("lock has no entry " + $path)
            else .packages[$path].integrity = $e.value end)
      ' package-lock.json > package-lock.json.tmp
      mv package-lock.json.tmp package-lock.json
    '';
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-V/ypqCpX2OpMisNgFfeUuOLKCBBmaxsO7PBMV8REWAk=";
    dontNpmBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R . "$out/"
      runHook postInstall
    '';
  };

in
{
  home.packages = [ pkgs.pi-coding-agent ];

  programs.zsh.shellAliases = {
    p = "pi";
    pc = "pi --continue";
  };

  home.file = {
    # Version-matched CLI reference plus the shared tab/authentication policy.
    ".pi/agent/skills/herdr/SKILL.md".source = "${pkgs.herdr}/share/skills/herdr/herdr/SKILL.md";
    ".pi/agent/AGENTS.md".source = ../doc/herdr-policy.md;

    # Pi discovers one directory deep under extensions.
    ".pi/agent/extensions/mcp-adapter".source = piMcpAdapter;

    # Match the shared enabled MCP catalogue with lazy startup for each server.
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
        workiq = {
          inherit (config.programs.mcp.servers.workiq) command args;
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

      };
    };
  };

  # Keep the generated herdr extension matched to the installed herdr version.
  home.activation.herdrPiIntegration = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if ! $DRY_RUN_CMD ${lib.getExe pkgs.herdr} integration install pi; then
      warnEcho "Herdr Pi integration failed; retry 'herdr integration install pi' and restart Pi."
    fi
  '';
}
