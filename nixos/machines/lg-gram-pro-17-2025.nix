# LG Gram Pro 17 2025 17Z90TP-G
{ ... }:
{
  system.stateVersion = "25.05";

  imports = [
    ../profiles/desktop.nix
    # ../profiles/factorio.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  # force new, xe video driver
  boot.kernelParams = [
    "xe.force_probe=7d51"
    "i915.force_probe=!7d51"
    # "acpi.ec_no_wakeup=1"
    "acpi_mask_gpe=0x6e"
  ];

  boot.blacklistedKernelModules = [ "i915" ];

  #boot.extraModprobeConfig = ''
  #  options iwlwifi power_save=Y
  #  options iwlwifi d0i3_disable=0
  #  options iwlwifi uapsd_disable=0
  #  options iwlwifi enable_ini=N
  #'';
}
