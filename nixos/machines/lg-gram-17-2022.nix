# LG Gram 17 2022 Intel 12th Gen
{ ... }:
{
  system.stateVersion = "23.05";

  imports = [
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_12th_gen.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];
}
