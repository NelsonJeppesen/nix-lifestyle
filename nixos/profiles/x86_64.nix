{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  virtualisation = {
    #docker = {
    #  enable = true;
    #};
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}
