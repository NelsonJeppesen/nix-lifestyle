# Shared LG Gram quirks (12th gen through Core Ultra)
#
# - Blacklists int3403_thermal to silence ACPI errors on the LGEC SEN2._TMP
#   region present across all generations of LG Gram DSDTs.
# - Loads the lg-laptop kernel module (Fn brightness, reader mode, battery
#   charge threshold via /sys/devices/platform/lg-laptop/battery_care_limit).
# - Caps battery charge at 80% on boot for longevity (LG WMI udev rule).
# - Disables Bluetooth at boot (small idle-power saving; toggle via
#   `bluetoothctl power on` or GNOME control center when needed).
{ pkgs, lib, ... }:
{
  # Fix ACPI errors:
  #   ACPI Error: No handler for Region [XIN1] (...) [UserDefinedRegion]
  #   ACPI Error: Region UserDefinedRegion (ID=143) has no handler
  #   ACPI Error: Aborting method \_SB.PC00.LPCB.LGEC.SEN2._TMP ...
  boot.blacklistedKernelModules = [ "int3403_thermal" ];

  # LG Gram WMI keys + battery charge threshold support
  boot.kernelModules = [ "lg-laptop" ];

  # Cap battery charge to 80% for longevity (lg-laptop exposes this sysfs entry)
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="platform", KERNEL=="lg-laptop", \
      RUN+="${pkgs.bash}/bin/sh -c 'echo 80 > /sys/devices/platform/lg-laptop/battery_care_limit'"
  '';

  # Power off Bluetooth at boot to save ~0.3 W when unused.
  hardware.bluetooth.powerOnBoot = lib.mkDefault false;

  services.upower.enable = lib.mkDefault true;
}
