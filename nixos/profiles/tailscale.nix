# tailscale.nix - Tailscale daemon with `nelson` as the operator.
# Marks tailscale0 as a trusted firewall interface so peer traffic
# bypasses the host firewall.
{ ... }:
{
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = [ "--operator=nelson" ];

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
