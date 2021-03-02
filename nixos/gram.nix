#
# LG Gram 17" 20201 (17Z90P K.AAB8U1)
#
{ config, pkgs, stdenv, lib, modulesPath, ... }:

{
  imports =
  [ (modulesPath + "/installer/scan/not-detected.nix")
     ./platforms/x86_64.nix
     ./platforms/intel.nix
     ./profiles/shared.nix
  ];

}
