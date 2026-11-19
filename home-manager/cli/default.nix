# Compose command-line features; each imported module owns one tool or workflow.
{ ... }: {
  imports = [
    ./bat.nix
    ./development-tools.nix
    ./git.nix
    ./gh-dash.nix
    ./mise.nix
    ./nix-index.nix
    ./ruby.nix
    ./scanner.nix
    ./zoxide.nix
    ./zsh.nix
    ./packages.nix
    ./files.nix
  ];
}
