# LG Gram 17 2022 Intel 12th Gen
{ ... }:
{
  system.stateVersion = "25.11";

  imports = [
    ../profiles/openclaw.nix
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/networking.nix
    #../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];
}
