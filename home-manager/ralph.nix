# ralph.nix - Open Ralph Wiggum CLI (iterative AI coding loop)
#
# `ralph "<prompt>" [options]` runs an AI coding agent in a loop, feeding it
# the same prompt each iteration until it emits a completion promise. Upstream:
# https://github.com/Th0rgal/open-ralph-wiggum
#
# Packaging notes:
# - Upstream is a Bun/TypeScript project with ZERO runtime npm deps (only a
#   @types/bun devDependency). The real logic is a single ralph.ts run via
#   `bun ralph.ts`; the published npm `bin/ralph.js` is just a Node->Bun shim.
#   So instead of the npm/node layer we wrap ralph.ts directly with bun.
# - The source is the `open-ralph-wiggum` non-flake input (see flake.nix),
#   passed through extraSpecialArgs.
# - OpenCode is upstream's DEFAULT agent (no --agent flag needed). It's already
#   installed via opencode.nix; we put it on the wrapper's PATH so `ralph`
#   works out of the box. `bun` is added to PATH too (the only hard runtime
#   dep). Other agents (claude-code, codex, copilot, …) remain opt-in via
#   `--agent` and are NOT pulled in here.
# - This is intentionally CLI-only; per upstream it must NOT be loaded as an
#   OpenCode plugin.
{
  pkgs,
  open-ralph-wiggum,
  ...
}:
let
  ralph = pkgs.writeShellApplication {
    name = "ralph";
    runtimeInputs = [
      pkgs.bun # required runtime: ralph.ts is executed by bun
      pkgs.opencode # default agent, so `ralph "..."` works with no --agent
    ];
    text = ''
      exec bun ${open-ralph-wiggum}/ralph.ts "$@"
    '';
  };
in
{
  home.packages = [ ralph ];
}
