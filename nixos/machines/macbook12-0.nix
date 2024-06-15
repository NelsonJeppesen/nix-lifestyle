# Apple MacBook 12
#
# The most cute server in the world
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }: {
  system.stateVersion = "23.11";

  imports = [
    # secrets
    ../profiles/agenix.nix

    # standard stuff
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/shared.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix

    # lets make this a k3s server
    ../profiles/agenix.nix
    ../profiles/k3s.nix
    ../profiles/macbook12-server.nix
    ../profiles/macbook12.nix
  ];

  # this is the first node of the k3s cluster
  services.k3s.clusterInit = true;

  services.atuin.enable = true;
  services.atuin.host = "0.0.0.0";
  services.atuin.openRegistration = true;
  services.atuin.openFirewall = true;
}
