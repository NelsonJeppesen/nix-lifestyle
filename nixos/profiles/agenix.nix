{
  imports = [ <agenix/modules/age.nix> ];
  environment.systemPackages = [ (pkgs.callPackage <agenix/pkgs/agenix.nix> { }) ];
}
