# agenix.nix - age-encrypted secrets management
#
# `agenix` is provided as a flake input via specialArgs (see ../flake.nix).
{ pkgs, agenix, ... }:
{
  imports = [ agenix.nixosModules.default ];
  # System secrets use these local identities even though SSH serving is off.
  # Preserve the existing private keys; a new installation must restore or
  # generate its own authorized identity before the first secret activation.
  age.identityPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_rsa_key"
  ];

  environment.systemPackages = [ agenix.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
