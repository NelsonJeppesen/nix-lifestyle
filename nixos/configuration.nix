# configuration.nix - Cross-host NixOS baseline
#
# Imported by every nixosConfigurations.* output in flake.nix together with
# the machine-specific module. Hostname is set in the flake's mkSystem
# helper, so this file no longer reads /etc/nixos/.hostname.
{ ... }:
{
  networking.domain = "home.arpa";

  imports = [
    # Default profiles applied on every host
    ./profiles/agenix.nix
    ./profiles/shared.nix
  ];
}
