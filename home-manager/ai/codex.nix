{ ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;

    # Home Manager owns config.toml; keep auth and sessions writable.
    settings.projects = {
      "/home/nelson/source/devops".trust_level = "trusted";
      "/home/nelson/source/personal/nix-lifestyle".trust_level = "trusted";
    };
  };
}
