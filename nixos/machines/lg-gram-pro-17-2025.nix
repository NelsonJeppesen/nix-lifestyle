# LG Gram Pro 17 2025 17Z90TP-G (Intel Core Ultra, Meteor/Arrow Lake)
{ lib, pkgs, ... }:
{
  system.stateVersion = "26.05";

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
    ../profiles/laptop_power.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/s3fs.nix
    ../profiles/tailscale.nix
    ../profiles/wifi.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];

  # GPU: force the new `xe` driver over `i915`.
  # NOTE: PCI ID 7d51 is Meteor Lake-P (Arc Graphics). On Arrow Lake the IDs
  # differ (7d67/7d45/64a0); verify with `lspci -nn | grep VGA` if upgrading.
  # The xe driver auto-binds on kernel >= 6.8 for most Meteor Lake IDs, so
  # `force_probe` may be unnecessary — but keeping it is harmless.
  boot.kernelParams = [
    "xe.force_probe=7d51"
    "i915.force_probe=!7d51"
    # "acpi.ec_no_wakeup=1"
    # GPE storm fix carried from 12th-gen LG Gram. Verify the offending GPE
    # is still 0x6e on this machine via:
    #   grep -v '   0$' /sys/firmware/acpi/interrupts/gpe*
    "acpi_mask_gpe=0x6e"
  ];

  boot.blacklistedKernelModules = [ "i915" ];

  # AX211 / BE200 Wi-Fi tuning + Intel SOF audio (Meteor/Arrow Lake).
  # AX211 is prone to disconnects with default power_save=1 + uapsd; both
  # workarounds below are widely used. SOF dsp_driver=3 forces the SOF stack
  # over the legacy HDA fallback (which gives "dummy output" on some Grams).
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 uapsd_disable=1
    options iwlmvm power_scheme=1
    options snd-intel-dspcfg dsp_driver=3
  '';

  # iwd power-save off (TLP's WIFI_PWR_* doesn't always reach iwd reliably).
  networking.wireless.iwd.settings = {
    General.EnableNetworkConfiguration = false;
    Scan.DisablePeriodicScan = false;
    DriverQuirks.DefaultPowerSave = false;
  };

  # Surface useful audio diagnostics packages
  environment.systemPackages = with pkgs; [
    sof-tools
    alsa-utils
  ];

  # lg_gram_common already disables Bluetooth at boot via mkDefault; allow
  # override here if ever desired.
  hardware.bluetooth.powerOnBoot = lib.mkForce false;
}
