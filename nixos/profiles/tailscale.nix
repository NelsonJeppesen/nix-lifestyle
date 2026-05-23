# tailscale.nix - Tailscale daemon with `nelson` as the operator.
# Marks tailscale0 as a trusted firewall interface so peer traffic
# bypasses the host firewall.
#
# DNS: systemd-resolved is enabled so tailscaled can register MagicDNS
# via resolved's DBus API (split DNS for the *.ts.net domain) instead
# of racing systemd-networkd over /etc/resolv.conf on boot. Without
# resolved, networkd's DHCP-driven resolv.conf rewrite clobbers
# tailscale's MagicDNS entries on first boot, and DNS only recovers
# after a manual `systemctl restart tailscaled`.
{ ... }:
{
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = [ "--operator=nelson" ];

  # Required for stable MagicDNS with systemd-networkd; tailscaled
  # talks to resolved over DBus to install per-interface resolvers.
  services.resolved.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
