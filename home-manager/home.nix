{ config, lib, pkgs, ... }:
# Add `openssh` to git-sync path so it can use sshkeys to sign my commits
let
  git-sync = pkgs.git-sync.overrideAttrs (oldAttrs: rec {
    wrapperPath = with lib; makeBinPath [
      pkgs.inotify-tools
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      pkgs.gnused
      pkgs.openssh
    ];
  });
in
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./git.nix
    ./gnome.nix
    ./kitty.nix
    ./neovim.nix
    ./shell.nix
  ];


  programs.home-manager.enable = true;

  # Add local scripts
  home.sessionPath = [ "/home/nelson/.local/bin" ];

  services.git-sync.enable = true;
  services.git-sync.package = git-sync; # use patched derivation
  services.git-sync.repositories.notes.uri = "manualy-git-clone-the-repo";
  services.git-sync.repositories.notes.path = "/home/nelson/s/notes";

  home = {
    stateVersion = "22.05";
    username = "nelson";
    homeDirectory = "/home/nelson";

    file.".local/bin".source = ../bin;
    file.".terraform.d/plugin-cache/.empty".source = ../dotfiles/empty;
    file.".curlrc".source = ../dotfiles/curlrc;
    file.".config/fend/config.toml".source = ../dotfiles/fend.toml;

    packages = [
      # jeppesen.io
      pkgs.hugo

      # nixpkgs maintainer
      pkgs.nixpkgs-review

      # fun
      pkgs.mindustry
      pkgs.vitetris
      pkgs.wesnoth
      pkgs.zeroad

      # formaters
      pkgs.shfmt
      pkgs.nixpkgs-fmt

      # chill
      pkgs.somafm-cli
      pkgs.spotify

      # core GUI apps
      pkgs.firefox
      pkgs.fractal
      pkgs.google-chrome
      pkgs.kitty
      pkgs.slack
      pkgs.zoom-us
      #pkgs.libreoffice

      # cloud management
      pkgs.awscli2
      pkgs.dbeaver
      pkgs.google-cloud-sdk
      pkgs.packer
      pkgs.ssm-session-manager-plugin
      pkgs.terraform

      # better shell scripts
      pkgs.shellcheck
      pkgs.shfmt

      # core shell tools
      pkgs.btop
      pkgs.choose
      pkgs.curl
      pkgs.dasel
      pkgs.dnsutils
      pkgs.entr
      pkgs.fd
      pkgs.fend
      pkgs.gh
      pkgs.jq
      pkgs.p7zip
      pkgs.ripgrep
      pkgs.tig
      pkgs.up
      pkgs.vault
      pkgs.wget
      pkgs.wl-clipboard

      # Kubernetes
      pkgs.aws-iam-authenticator
      pkgs.glooctl
      pkgs.helmfile
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.sops
      pkgs.stern
    ];
  };
}
