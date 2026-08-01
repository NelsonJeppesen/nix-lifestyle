# nix-index.nix - Prebuilt package-file index and ad-hoc command runner
{
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # Uses nix-index-database's weekly prebuilt binaries-only database. No local
  # package indexing is performed during activation.
  programs.nix-index-database.comma.enable = true;
}
