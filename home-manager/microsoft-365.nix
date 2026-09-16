# Microsoft 365 tools shared by the coding agents, with interactive login.
{
  lib,
  pkgs,
  ms-365-mcp-server,
  ms-365-mcp-release,
  ...
}:
let
  ms365 = pkgs.buildNpmPackage {
    pname = "ms-365-mcp-server";
    version = "0.154.0";
    src = ms-365-mcp-server;
    npmDepsFetcherVersion = 2;
    npmDepsHash = "sha256-bdN+CZObXWA0Jy4N9LyI8q8ypLKisRWbuS2kiEVIMOE=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.libsecret ];
    # The published release includes generated Graph clients. Upstream's
    # generator downloads live schemas and an unpinned tool through npx;
    # use the matching release assets with the source's locked dependencies.
    dontNpmBuild = true;
    postPatch = ''
      cp -R ${ms-365-mcp-release}/dist ./dist
    '';
    meta.mainProgram = "ms-365-mcp-server";
  };
in
{
  programs.mcp.servers.ms365 = {
    command = lib.getExe ms365;
    args = [
      "--org-mode"
      "--discovery"
    ];
    enabled = true;
  };

  home.packages = [ ms365 ]; # Microsoft 365 MCP server and login CLI
}
