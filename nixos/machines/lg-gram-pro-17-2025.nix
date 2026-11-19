# LG Gram Pro 17 2025 17Z90TP-G (Intel Core Ultra 7 255H, Arrow Lake-H)
{ pkgs, ... }:
{
  # Compatibility defaults for stateful services; do not bump during upgrades.
  system.stateVersion = "26.05";

  # Stable identity of the disk backing /boot and /dev/mapper/crypted.
  # NVMe numeric names can exchange places between boots. This selects the
  # destructive installation target; ordinary rebuilds do not repartition it.
  disko.devices.disk.vdb.device = "/dev/disk/by-id/nvme-eui.002538b2514012f8";

  imports = [
    ../profiles/chrome-policies.nix
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/keychron.nix
    ../profiles/laptop_power.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/nix-ld.nix
    ../profiles/plymouth.nix
    ../profiles/s3fs.nix
    ../profiles/storage-maintenance.nix
    ../profiles/scanner.nix
    ../profiles/tailscale.nix
    ../profiles/wifi.nix
    ../profiles/x86_64.nix
  ];

  # GPU: `i915`, not `xe`. 7d51 is this Arrow Lake-H iGPU (check with
  # `cat /sys/class/drm/card*/device/device`).
  #
  # Workaround for xe hard freezes preceded by "TLB invalidation fence
  # timeout, seqno=N
  # recv=N-1". Cause: the standalone media GT's GuC acks TLB invalidations
  # through a CTB that xe maps CPU-cached, and on MTL/ARL that mapping
  # isn't coherent, so the CPU reads the ack ~2.3 s late. i915 has the
  # fix (Wa_22016122933, uncached GuC buffers on media GT 13.00); xe
  # doesn't. No BIOS setting or GuC update helps (70.53.0 is the only ARL
  # GuC). Upstream: drm/xe work item 8678, issue 8760; patch "drm/xe: fix
  # GuC TLB invalidation ack stalls on ARL" (v6, Sep 2026, unmerged).
  #
  # Retry xe only once the kernel has the workaround:
  #   xz -dc $(modinfo -n xe) | grep -ac 22016122933   # must be > 0
  # then add "xe.force_probe=7d51" "i915.force_probe=!7d51" to kernelParams
  # and swap the blacklist and initrd.kernelModules to xe. i915 binds 7d51
  # natively, so it needs no force_probe.
  boot.kernelParams = [
    # "acpi.ec_no_wakeup=1"
    # Workaround for a firmware GPE storm. Verify the offending GPE
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

  boot.blacklistedKernelModules = [ "xe" ];
  boot.initrd.kernelModules = [ "i915" ];

  # 2880x1800 panel: Plymouth's auto-detect picks 1x and renders the splash
  # postage-stamp sized. 2x makes the logical canvas 1440x900, the splash
  # frames' exact size, so it fills the screen with no script-side resize;
  # see profiles/plymouth.nix for the geometry it must match.
  boot.plymouth.extraConfig = ''
    DeviceScale=2
  '';

  # Disable Intel Wi-Fi power saving for link reliability. iwlmvm settings
  # apply only when that op-mode is loaded; kernels using iwlmld ignore them.
  # SOF dsp_driver=3 selects the DSP audio stack required by this hardware.
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
