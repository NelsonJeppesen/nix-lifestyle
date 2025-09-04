# LG Gram 14 2022 14Z90Q-K.ARW5U1 Intel 12th Gen
{ ... }:
{
  system.stateVersion = "22.11";

  imports = [
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_12th_gen.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix

    /etc/secrets/falcon.nix
  ];

  nixpkgs.overlays = [
    (self: super: { falcon-sensor = super.callPackage ../overlays/falcon-sensor.nix { }; })
  ];

  # 8GiB laptop; things get tight
  zramSwap.memoryPercent = 100;

  # force xe driver for lg-gram-14-2022.home.arpa
  boot.kernelParams = [
    "xe.force_probe=46a6"
    "i915.force_probe=!46a6"
  ];
}
