# comin.nix - GitOps deployment via nlewo/comin
#
# Polls this repo's `main` branch every 60s and runs
# `nixos-rebuild switch` against `nixosConfigurations.<hostname>` whenever
# a new commit appears. Lets us reconfigure remote/headless hosts (currently
# just openclaw) without ssh.
#
# `comin` is a flake input forwarded via specialArgs (see ../flake.nix).
# Repo is public, so no auth_token_path is needed. Repo SSH-signature policy
# is enforced upstream by branch protection; comin's GPG check is skipped.
{ comin, config, ... }:
{
  imports = [ comin.nixosModules.comin ];

  services.comin = {
    enable = true;
    # Explicit even though it defaults to networking.hostName — surfaces the
    # contract that the flake output name must match the hostname.
    hostname = config.networking.hostName;
    # The flake lives in nixos/, not the repo root.
    repositorySubdir = "nixos";
    remotes = [
      {
        name = "origin";
        url = "https://github.com/NelsonJeppesen/nix-lifestyle.git";
        branches.main = {
          name = "main";
          operation = "switch";
        };
        poller.period = 60;
      }
    ];
    # Keep a few extra boot entries so a bad deploy is one rollback away.
    # systemd-boot configurationLimit = 14 (see profiles/desktop.nix) gives
    # plenty of headroom above this.
    retention.deployment_boot_entry_capacity = 5;
  };
}
