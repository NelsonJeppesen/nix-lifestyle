{ config, pkgs, stdenv, lib, ... }:

{
  boot.kernelPackages =  pkgs.linuxPackages_latest;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  virtualisation.docker.enable = true;
}
