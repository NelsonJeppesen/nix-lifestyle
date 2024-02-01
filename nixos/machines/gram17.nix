# LG Gram 14 14Z90Q-K.ARW5U1  Intel 12th Gen
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }:
{
  system.stateVersion = "23.05";

  programs.steam.enable = true;

  imports = [
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_12th_gen.nix
    ../profiles/networking.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];
}
