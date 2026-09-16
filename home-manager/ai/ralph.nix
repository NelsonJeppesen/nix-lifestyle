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
