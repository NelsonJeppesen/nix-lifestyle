# USB document scanners through SANE. The ScanSnap S1500 uses the free
# fujitsu backend; the proprietary epjitsu firmware option is unnecessary.
{ ... }:
{
  hardware.sane.enable = true;

  # Group membership also permits scans from SSH sessions without a seat ACL.
  # Set members here to preserve the baseline's mkDefault extraGroups list.
  users.groups.scanner.members = [ "nelson" ];
}
