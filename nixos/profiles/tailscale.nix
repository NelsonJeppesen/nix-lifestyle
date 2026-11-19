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
  # The VPN remains available, but its separate SSH server must stay off too.
  services.tailscale.extraSetFlags = [
    "--operator=nelson"
    "--ssh=false"
  ];

  # tailscaled talks to resolved over DBus to install per-interface resolvers.
  services.resolved.enable = true;

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
