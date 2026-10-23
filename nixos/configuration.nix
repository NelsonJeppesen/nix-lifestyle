# configuration.nix - Cross-host NixOS baseline
#
# Imported by every nixosConfigurations.* output in flake.nix together with
# the machine-specific module. Hostname is set in the flake's mkSystem
# helper.
{ ... }:
{
  networking.domain = "home.arpa";

  imports = [
    # Default profiles applied on every host
    ./profiles/agenix.nix
    ./profiles/shared.nix
  ];
}
