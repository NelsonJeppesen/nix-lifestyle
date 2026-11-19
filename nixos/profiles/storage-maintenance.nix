# Verify checksums of allocated data and metadata on the root Btrfs filesystem.
# Scrub can repair only from a good redundant copy; it is not a backup mechanism.
{ ... }:
{
  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
    interval = "monthly";
  };

  # The pinned module supplies a persistent timer, Nice=19, and idle CPU/IO
  # scheduling. AC gating avoids starting a disk-wide scan on laptop battery.
  # A skipped start waits for the next timer window or an explicit AC start;
  # plugging in alone does not trigger a retry (see nixos/README.md).
  systemd.services."btrfs-scrub@".unitConfig.ConditionACPower = true;
}
