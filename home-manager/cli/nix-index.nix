{
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  # Uses nix-index-database's weekly prebuilt binaries-only database.
  programs.nix-index-database.comma.enable = true;
}
