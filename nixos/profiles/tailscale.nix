# tailscale.nix - Tailscale daemon with `nelson` as the operator.
# Marks tailscale0 as a trusted firewall interface so peer traffic
# bypasses the host firewall.
#
# DNS: systemd-resolved is enabled so tailscaled can register MagicDNS
# via resolved's DBus API (split DNS for the *.ts.net domain) instead
# of rewriting /etc/resolv.conf, which NetworkManager also manages.
{ ... }:
{
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = [ "--operator=nelson" ];

  # tailscaled talks to resolved over DBus to install per-interface resolvers.
  services.resolved.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
