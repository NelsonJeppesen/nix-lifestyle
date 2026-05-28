# factorio.nix - Install Factorio from a pinned nixpkgs revision.
#
# Factorio's upstream derivation fetches the alpha tarball from
# factorio.com and normally needs `username`/`token` to authenticate.
# Instead, the tarball was placed into the Nix store once via:
#
#   nix-prefetch-url --type sha256 \
#     --name factorio_alpha_x64-2.0.76.tar.xz \
#     "https://factorio.com/get-download/2.0.76/alpha/linux64?username=<U>&token=<T>"
#
# Because nixpkgs evolves (and bumps Factorio's expected hash), we pull
# `factorio` from a frozen nixpkgs input (`nixpkgs-factorio`, pinned in
# ../flake.nix) so the main `nixpkgs` can roll forward without breaking
# this offline install.
#
# To upgrade Factorio:
#   1. Bump `nixpkgs-factorio.url` rev in flake.nix to one shipping the
#      new version.
#   2. Re-run the nix-prefetch-url above with the new <VER>.
#   3. `nix flake lock --update-input nixpkgs-factorio` in nixos/.
{ pkgs, nixpkgs-factorio, ... }:
let
  # Re-import the pinned nixpkgs with the same config as the running
  # system (so `allowUnfree` propagates — factorio is unfree).
  pkgsFactorio = import nixpkgs-factorio {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  environment.systemPackages = [ pkgsFactorio.factorio ];
}
