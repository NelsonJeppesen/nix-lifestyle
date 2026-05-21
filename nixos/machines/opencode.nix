# opencode — Apple MacBook 12, repurposed as a tailnet-only opencode server.
#
# Hosts the `opencode serve` HTTP API (loopback) fronted by `tailscale serve`
# for HTTPS on the tailnet. Managed remotely via comin (see profiles/comin.nix);
# manual rebuilds are only needed for the initial bootstrap.
#
# This host used to be `macbook12-0` and ran wireguard / route53-updater /
# atuin in addition to k3s. All of that was stripped when the box was
# repurposed for opencode — see git history for the prior config if you
# need to resurrect any of it.
{ ... }:
{
  system.stateVersion = "24.11";

  imports = [
    # macbook12 hardware (initrd modules, console tuning for the retina TTY).
    ../profiles/macbook12.nix
    # Headless laptop server quirks (lid-close = no sleep, console blanking).
    ../profiles/macbook12-server.nix

    # Cross-host hardware baseline (Intel iGPU, x86_64 disko, networking).
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/x86_64.nix

    # The actual workload + its tailnet HTTPS frontend.
    ../profiles/opencode.nix
    ../profiles/tailscale.nix

    # GitOps: this host reconfigures itself from the repo on every push.
    ../profiles/comin.nix
  ];
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.settings = {
    General.EnableNetworkConfiguration = false;
  };

}
