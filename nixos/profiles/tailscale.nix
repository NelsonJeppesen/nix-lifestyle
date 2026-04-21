{ ... }:
{
  services.tailscale.enable = true;
  services.tailscale.extraSetFlags = [ "--operator=nelson" ];

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
