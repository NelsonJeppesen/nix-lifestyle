# Shared LG Gram quirks (12th gen through Core Ultra)
#
# - Blacklists int3403_thermal to silence ACPI errors on the LGEC SEN2._TMP
#   region present across all generations of LG Gram DSDTs.
# - Loads the lg-laptop kernel module (Fn brightness, reader mode, and
#   battery charge threshold via /sys/devices/platform/lg-laptop/battery_care_limit).
# - Enables upower so battery state is reported to the desktop.
#
# Battery charge cap and Bluetooth power-on policy are now configured per
# machine (or in laptop_power.nix) rather than here.
{ lib, ... }:
{
  # Fix ACPI errors:
  #   ACPI Error: No handler for Region [XIN1] (...) [UserDefinedRegion]
  #   ACPI Error: Region UserDefinedRegion (ID=143) has no handler
  #   ACPI Error: Aborting method \_SB.PC00.LPCB.LGEC.SEN2._TMP ...
  boot.blacklistedKernelModules = [ "int3403_thermal" ];

  # LG Gram WMI keys + battery charge threshold support
  boot.kernelModules = [ "lg-laptop" ];

  services.upower.enable = lib.mkDefault true;
}
