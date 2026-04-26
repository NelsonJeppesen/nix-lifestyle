{ pkgs, ... }:
let
  oc-standup = pkgs.writeShellApplication {
    name = "oc-standup";
    text = builtins.readFile ./oc-standup.sh;
    runtimeInputs = with pkgs; [
      atuin
      coreutils
      findutils
      gawk
      gh
      git
      gitleaks
      gnugrep
      gnused
      jq
      openssh
      util-linux
    ];
  };
in
{
  home.packages = [
    oc-standup # Generate daily standup notes from shell, session, and git activity
  ];

  programs.opencode.commands.standup = ''
    # Generate Standup Notes
    Run the user's `oc-standup` command via the Bash tool with no arguments.
    Stream stderr/stdout to the user. After it exits, read the generated
    standup file if one was written and show it to the user.
  '';
}
