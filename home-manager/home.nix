# Compose independent feature categories; shared user identity lives in other.nix.
{ ... }: {
  imports = [
    ./gnome
    ./cli
    ./neovim
    ./gui
    ./ai
    ./other.nix
  ];
}
