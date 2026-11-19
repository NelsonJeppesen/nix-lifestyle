# Laptop power policy (TLP + iwd), explicitly imported by laptop machines.
# Hardware-specific charge limits belong in lg_gram_common.nix.
#
# Intel HWP uses the powersave governor with an energy-performance preference
# (EPP): performance on AC for responsiveness, power on battery for efficiency.
# Actual throughput, temperatures, and battery cost depend on host and workload.
# USB autosuspend and Wi-Fi power saving are disabled for input/link reliability;
# these choices trade idle power for responsiveness. Review with tlp-stat and
# repeatable workloads before tightening power limits.
{ lib, ... }:
{
  services.thermald.enable = false;

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
    # Applied only on hardware exposing the ACPI platform_profile interface.
    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

    # Prefer responsiveness for bursty editor/terminal workloads on AC,
    # and energy efficiency on battery. Measure latency and power per host.
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
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

    # Request modern standby; confirm supported modes in /sys/power/mem_sleep.
    MEM_SLEEP_ON_AC = "s2idle";
    MEM_SLEEP_ON_BAT = "s2idle";

    NMI_WATCHDOG = 0;

    # NVMe APST uses the kernel defaults. TLP does not implement NVME_APST_*
    # settings; PCI runtime PM below is a separate mechanism.

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

    # Workaround for HID/BT input lag when Logitech receivers (046d:c52b,
    # 046d:c548) or the internal BT controller (8087:0037) autosuspend.
    # This disables autosuspend for all USB devices; a measured per-device
    # denylist is an alternative when battery life matters more.
    USB_AUTOSUSPEND = 0;
    USB_EXCLUDE_PHONE = 1;

    # Keep Wi-Fi awake to avoid power-save-related disconnects. This costs
    # idle power; revisit after validating the actual adapter/firmware pair.
    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "off";

    WOL_DISABLE = "Y";
  };

  # iwd is preferred on modern Intel Wi-Fi (AX2xx / BE2xx).
  networking.networkmanager.wifi.backend = "iwd";

  # powertop --auto-tune disabled: it unconditionally writes 'auto' to every
  # USB device's power/control, which silently undoes USB_AUTOSUSPEND=0 above
  # and re-introduces HID/BT input lag. TLP alone covers the same ground for
  # the knobs we actually want.
  powerManagement.powertop.enable = false;
}
