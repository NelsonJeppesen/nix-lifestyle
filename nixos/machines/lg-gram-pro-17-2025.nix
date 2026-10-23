# LG Gram Pro 17 2025 17Z90TP-G (Intel Core Ultra 7 255H, Arrow Lake-H)
{ pkgs, ... }:
{
  system.stateVersion = "26.05";

  imports = [
    ../profiles/chrome-policies.nix
    ../profiles/console.nix
    ../profiles/desktop.nix
    ../profiles/factorio.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/keychron.nix
    ../profiles/laptop_power.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/nix-ld.nix
    ../profiles/plymouth.nix
    ../profiles/s3fs.nix
    ../profiles/tailscale.nix
    ../profiles/wifi.nix
    ../profiles/x86_64.nix
  ];

  # GPU: `xe`, like lg-gram-14-2022. 7d51 is this Arrow Lake-H iGPU (check
  # with `cat /sys/class/drm/card*/device/device`). xe still needs
  # force_probe for it, and i915 is kept off the device.
  #
  # This host ran i915 until Oct 2026 because xe hit repeated TLB
  # invalidation fence timeouts and hard freezes, including in suspend and
  # resume. If those return, boot the previous generation, then swap the
  # force_probe values and the blacklist back to i915.
  boot.kernelParams = [
    "xe.force_probe=7d51"
    "i915.force_probe=!7d51"
    # "acpi.ec_no_wakeup=1"
    # GPE storm fix carried from 12th-gen LG Gram. Verify the offending GPE
    # is still 0x6e on this machine via:
    #   grep -v '   0$' /sys/firmware/acpi/interrupts/gpe*
    "acpi_mask_gpe=0x6e"
    # i8042/EC race at cold boot intermittently fails controller probe
    # ("Can't read CTR ... probe with driver i8042 failed with error -5"),
    # leaving the internal keyboard dead until the next power cycle.
    # `probe_defer` retries the probe via deferred-probe once dependent
    # platform/EC drivers are up — this is what actually rescues the
    # cold-boot CTR-read race; `reset=force` alone runs too late because
    # the driver bails on the very first CTR read failure. `kbdreset`
    # resets the keyboard device on the KBD port (independent of the
    # controller reset). `nopnp` + `unlock` are kept for completeness.
    "i8042.reset=force"
    "i8042.nopnp"
    "i8042.unlock"
    "i8042.probe_defer"
    "i8042.kbdreset"
  ];

  boot.blacklistedKernelModules = [ "i915" ];

  # 2880x1800 panel: Plymouth's auto-detect picks 1x and renders the splash
  # postage-stamp sized. 2x makes the logical canvas 1440x900, the splash
  # frames' exact size, so it fills the screen with no script-side resize;
  # see profiles/plymouth.nix for the geometry it must match.
  boot.plymouth.extraConfig = ''
    DeviceScale=2
  '';

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
  # Note: `DriverQuirks.DefaultPowerSave` is not a real iwd option (the key
  # in `iwd.config(5)` is `PowerSaveDisable`, and it expects a comma-separated
  # driver glob, not a boolean). Radio power-save is handled by the iwlwifi
  # modprobe options above instead.
  networking.wireless.iwd.settings = {
    General.EnableNetworkConfiguration = false;
    Scan.DisablePeriodicScan = false;
  };

  # Surface useful audio diagnostics packages
  environment.systemPackages = with pkgs; [
    sof-tools
    alsa-utils
  ];
}
