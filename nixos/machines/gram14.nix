# LG Gram 14 14Z90Q-K.ARW5U1  Intel 12th Gen
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }:
{
  system.stateVersion = "22.11";

  imports = [
    #../profiles/software_defined_radio.nix
    "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ../falcon/falcon.nix

    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_12th_gen.nix
    ../profiles/networking.nix
    ../profiles/shared.nix
    ../profiles/systemd-boot.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  nixpkgs.overlays = [
    (
      self: super: { falcon-sensor = super.callPackage ../overlays/falcon-sensor.nix { }; }
    )
  ];

  # laptop has 8gb of ram and it can get tight sometimes
  zramSwap.memoryPercent = 100;
}
