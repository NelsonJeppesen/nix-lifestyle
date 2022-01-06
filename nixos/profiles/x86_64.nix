{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages           = pkgs.linuxPackages_latest;
  virtualisation.docker.enable  = lib.mkDefault true;
}
