{ ... }: {
  imports = [
    ./ansible.nix
    ./bat.nix
    ./development-tools.nix
    ./git.nix
    ./gh-dash.nix
    ./mise.nix
    ./nix-index.nix
    ./ruby.nix
    ./zoxide.nix
    ./zsh.nix
    ./packages.nix
    ./files.nix
  ];
}
