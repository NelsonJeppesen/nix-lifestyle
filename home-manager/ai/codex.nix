{ ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;
    # Merge declared settings into a writable config.toml instead of a store
    # symlink: the ChatGPT/Codex app writes its bundled-plugin marketplace
    # there on every start and logs "Read-only file system" otherwise.
    mutableSettings = true;

    settings.projects = {
      "/home/nelson/source/devops".trust_level = "trusted";
      "/home/nelson/source/personal/nix-lifestyle".trust_level = "trusted";
    };
  };
}
