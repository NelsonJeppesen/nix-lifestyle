{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;

  virtualisation = {
    # dont think I'll go back to docker
    docker = {
      enable = true;
    };
    podman = {
      enable = true;
    #  dockerCompat = true;
    };
  };
}
