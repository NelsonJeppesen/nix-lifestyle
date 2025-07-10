# LG Gram 12th gen
{ ... }:
{
  # Fix ACPI errors
  #
  #   ACPI Error: No handler for Region [XIN1] (000000005158740d) [UserDefinedRegion] (20221020/evregion-130)
  #   ACPI Error: Region UserDefinedRegion (ID=143) has no handler (20221020/exfldio-261)
  #   ACPI Error: Aborting method \_SB.PC00.LPCB.LGEC.SEN2._TMP due to previous error (AE_NOT_EXIST) (20221020/psparse-529)
  boot.blacklistedKernelModules = [ "int3403_thermal" ];

  #systemd.services = {
  #  enable_fn_lock = {
  #    script = "echo 1 > /sys/devices/platform/lg-laptop/fn_lock";
  #    wantedBy = [ "multi-user.target" ];
  #  };

  #  #  script = "echo unmask > /sys/firmware/acpi/interrupts/gpe6E";
  #  #  wantedBy = [ "multi-user.target" ];
  #  #};
  #};

  #fix_usbc_dock_cpu_usage = {
  #boot.kernelParams = [ "acpi_mask_gpe=0x6E" ];
  networking.networkmanager.wifi.scanRandMacAddress = false;

  boot.extraModprobeConfig = ''
    #options iwlwifi disable_11ax=Y disable_11be=Y disable_11ac=N 11n_disable=0 amsdu_size=1
    ## amsdu_size:amsdu size
    ##   0: 12K for multi Rx queue devices, 2K for AX210 devices, 4K for other devices
    ##   1: 4K
    ##   2: 8K
    ##   3: 12K (16K buffers)
    ##   4: 2K
    #options iwlmvm power_scheme=1
  '';
}
