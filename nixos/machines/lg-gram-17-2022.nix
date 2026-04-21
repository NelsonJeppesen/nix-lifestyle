# LG Gram 17 2022 Intel 12th Gen
{ ... }:
{
  system.stateVersion = "23.05";

  imports = [
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/laptop_power.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  # force the use of more modern xe video driver over i915
  #boot.blacklistedKernelModules = [ "i915" ];

  #boot.kernelParams = [
  #  "xe.force_probe=46a6"
  #  "i915.force_probe=!46a6"
  #];
}
