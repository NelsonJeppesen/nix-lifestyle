# Apple MacBook 12
#
# The most cute server in the world
{ fetchurl, fetchgit, fetchhg, config, pkgs, stdenv, lib, modulesPath, ... }: {
  system.stateVersion = "23.11";

  imports = [
    # standard stuff
    ../profiles/intel.nix
    ../profiles/networking.nix
    ../profiles/x86_64.nix
    ../profiles/zsh.nix

    # lets make this a k3s server
    ../profiles/k3s.nix
    ../profiles/macbook12-server.nix
    ../profiles/macbook12.nix
  ];

  # node with `services.k3s.clusterInit = true;` set
  services.k3s.serverAddr = "https://192.168.5.0:6443";
}
