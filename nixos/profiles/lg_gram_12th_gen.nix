# LG Gram 12th gen
{ ... }:
{
  # Fix ACPI errors
  #
  #   ACPI Error: No handler for Region [XIN1] (000000005158740d) [UserDefinedRegion] (20221020/evregion-130)
  #   ACPI Error: Region UserDefinedRegion (ID=143) has no handler (20221020/exfldio-261)
  #   ACPI Error: Aborting method \_SB.PC00.LPCB.LGEC.SEN2._TMP due to previous error (AE_NOT_EXIST) (20221020/psparse-529)
  boot.blacklistedKernelModules = [ "int3403_thermal" ];
}
