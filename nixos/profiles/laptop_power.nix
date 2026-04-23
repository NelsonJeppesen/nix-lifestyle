# Laptop power profile (TLP + iwd) — applies to all laptops, regardless of
# CPU vendor. Previously these settings lived in profiles/intel.nix, which
# meant Intel desktops/NUCs also got battery-oriented TLP defaults.
#
# Tuned for Intel Core Ultra (Meteor/Arrow Lake) hybrid P+E core CPUs:
# - powersave governor on both AC and BAT; energy preference (EPP) is the
#   real knob with HWP. The performance governor on a hybrid CPU pegs
#   frequencies and increases throttling, *reducing* sustained throughput.
# - CPU_MAX_PERF kept at 100 on both rails; capping max_perf_pct interferes
#   with Intel Thread Director's E-core preference.
# - thermald is disabled (HWP + DPTF firmware handle thermals on Core Ultra).
# - PCIe ASPM powersupersave on battery (enables L1.2 substates).
# - WIFI_PWR forced off — Intel AX211/BE200 powersave causes disconnects
#   (cost: ~0.5-1 W).
# - powertop --auto-tune at boot (additive, mostly idempotent with TLP).
{ lib, ... }:
{
  services.thermald.enable = false;

  # TLP <=1.9.x still writes vm.laptop_mode (deprecated since kernel 6.5,
  # ignored by the kernel which logs a warning on every change). Pre-set the
  # sysctl so TLP's write is a no-op and the dmesg/journal noise stops.
  # Safe to remove once TLP drops the write (>=1.6 upstream, but still
  # present in 1.9.1 nixpkgs). See `tlp: vm.laptop_mode is deprecated`.
  boot.kernel.sysctl."vm.laptop_mode" = 0;

  # Suppress systemd-rfkill: NixOS's TLP module already masks it (TLP manages
  # radio devices itself), but masking alone still leaves the rfkill udev
  # rule's `SYSTEMD_WANTS=systemd-rfkill.service` triggering "Failed to
  # enqueue SYSTEMD_WANTS job, ignoring: Unit systemd-rfkill.socket is
  # masked" on every rfkill device add. Suppressing the unit entirely
  # silences the udev/systemd contention.
  systemd.suppressedSystemUnits = [
    "systemd-rfkill.service"
    "systemd-rfkill.socket"
  ];

  # TLP and power-profiles-daemon are mutually exclusive.
  services.power-profiles-daemon.enable = false;

  services.tlp.enable = lib.mkDefault true;
  services.tlp.settings = {
    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

    CPU_MAX_PERF_ON_AC = 100;
    CPU_MAX_PERF_ON_BAT = 100;

    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 1;

    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;

    AHCI_RUNTIME_PM_ON_AC = "auto";
    AHCI_RUNTIME_PM_ON_BAT = "auto";
    AHCI_RUNTIME_PM_TIMEOUT = 15;

    # LG Gram only supports s2idle (modern standby) on both AC and BAT.
    MEM_SLEEP_ON_AC = "s2idle";
    MEM_SLEEP_ON_BAT = "s2idle";

    NMI_WATCHDOG = 0;

    NVME_APST_ON_AC = 1;
    NVME_APST_ON_BAT = 1;
    NVME_APST_MAX_LATENCY_ON_AC = 70000;
    NVME_APST_MAX_LATENCY_ON_BAT = 100000;

    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";

    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "auto";

    SATA_LINKPWR_ON_AC = "med_power_with_dipm";
    SATA_LINKPWR_ON_BAT = "min_power";

    SOUND_POWER_SAVE_CONTROLLER = "Y";
    SOUND_POWER_SAVE_ON_AC = 0;
    # 1s autosuspend (10s caused pop-on-resume on some LG Gram revisions)
    SOUND_POWER_SAVE_ON_BAT = 1;

    USB_AUTOSUSPEND = 1;
    USB_DENYLIST_BTUSB = 1;
    USB_EXCLUDE_PHONE = 1;

    # AX211/BE200 hate powersave=1 — leave OFF on both rails (cost ~0.5-1 W
    # for stable connectivity).
    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "off";

    WOL_DISABLE = "Y";
  };

  # iwd is preferred on modern Intel Wi-Fi (AX2xx / BE2xx).
  networking.networkmanager.wifi.backend = "iwd";

  # powertop --auto-tune at boot (additive to TLP, mostly idempotent)
  powerManagement.powertop.enable = true;
}
