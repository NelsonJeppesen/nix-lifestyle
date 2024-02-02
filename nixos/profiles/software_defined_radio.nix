{ config, pkgs, stdenv, lib, ... }:

{
  hardware.rtl-sdr.enable = lib.mkDefault true;
  environment.systemPackages = with pkgs; [ sdrpp ];
}
