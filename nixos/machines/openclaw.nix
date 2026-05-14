# openclaw — stationary LG Gram running the openclaw gateway service.
# Managed remotely via comin (see profiles/comin.nix); manual rebuilds are
# only needed for the initial bootstrap.
#
# `laptop_power.nix` is intentionally NOT imported: this host is always on
# AC, and TLP's powersave defaults trade gateway responsiveness for ~1W of
# savings we don't care about here.
{ ... }:
{
  system.stateVersion = "26.05";

  imports = [
    ../profiles/comin.nix
    ../profiles/desktop.nix
    ../profiles/gnome.nix
    ../profiles/intel.nix
    ../profiles/lg_gram_common.nix
    ../profiles/networking.nix
    ../profiles/openclaw.nix
    ../profiles/tailscale.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix
  ];
}
