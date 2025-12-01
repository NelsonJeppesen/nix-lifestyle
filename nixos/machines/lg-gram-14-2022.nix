# LG Gram 14 2022 14Z90Q-K.ARW5U1 Intel 12th Gen
{ ... }:
{
  system.stateVersion = "25.05";

  imports = [
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_12th_gen.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  # force new, xe video driver
  boot.kernelParams = [
    "xe.force_probe=46a6"
    "i915.force_probe=!46a6"
    # "acpi.ec_no_wakeup=1"
    "acpi_mask_gpe=0x6e"
  ];

  boot.blacklistedKernelModules = [ "i915" ];

  # 8GiB laptop; things get tight
  zramSwap.memoryPercent = 100;
}
