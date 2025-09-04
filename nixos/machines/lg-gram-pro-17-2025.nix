# LG Gram Pro 17 2025 17Z90TP-G
{ ... }: {
  system.stateVersion = "25.05";

  imports = [
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];
}
