# LG Gram Pro 17 2025 17Z90TP-G
{ ... }:
{
  system.stateVersion = "25.05";

  # nixpkgs.hostPlatform = {
  #   gcc.arch = "native";
  #   gcc.tune = "native";
  #   system = "x86_64-linux";
  # };

  imports = [
    # ../profiles/factorio.nix
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/wifi.nix
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

  boot.extraModprobeConfig = ''
    # options iwlwifi power_save=0
    # options iwlwifi uapsd_disable=1
  '';
}
