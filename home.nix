{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./gnome.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/neovim.nix
    ./programs/shell.nix
  ];

  home = {

    programs.home-manager.enable = true;

    packages = [
      #pkgs.aws-iam-authenticator
      pkgs.awscli2
      pkgs.curl
      pkgs.dnsutils
      pkgs.gnomeExtensions.appindicator
      pkgs.gnomeExtensions.caffeine
      pkgs.gnomeExtensions.clipboard-indicator
      pkgs.gnomeExtensions.paperwm
      pkgs.google-chrome
      pkgs.helmfile
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.ripgrep
      pkgs.rnix-lsp
      pkgs.slack
      pkgs.sops
      pkgs.spotify
      pkgs.ssm-session-manager-plugin
      pkgs.terraform_0_13
      pkgs.wget
      pkgs.wmctrl
    ];
  };
}
