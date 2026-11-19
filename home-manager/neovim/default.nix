# Compose the nvf editor configuration and supporting user packages.
{ ... }: {
  imports = [
    ./nvf.nix
    ./packages.nix
  ];
}
