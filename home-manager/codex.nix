# codex.nix - OpenAI Codex coding assistant configuration
{ ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = false;
  };
}
