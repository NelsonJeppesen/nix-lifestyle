# Install static OpenCode plugin settings independently of plugin enablement.
{ ... }: {
  home.file.".config/opencode/open-plan-annotator.json".source = ./dotfiles/open-plan-annotator.json; # open-plan-annotator: hand off approved plans to the `build` agent
}
