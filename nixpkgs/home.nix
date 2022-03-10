{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./git.nix
    ./gnome-paperwm.nix
    ./kitty.nix
    ./neovim.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  # Add local scripts
  home.sessionPath = [ "/home/nelson/.local/bin" ];

  services.git-sync.enable = true;
  services.git-sync.repositories.notes.uri = "bogus";
  services.git-sync.repositories.notes.path = "/home/nelson/s/notes";

  home = {

     #file.".config/tuir/tuir.cfg".source = dotfiles/tuir.cfg;
     file.".local/bin".source = ./bin;
     file.".terraform.d/plugin-cache/.empty".source = dotfiles/empty;
     file.".curlrc".source = dotfiles/curlrc;
     file.".config/fend/config.toml".source = dotfiles/fend.toml;

     packages = [
      # jeppesen.io
      pkgs.hugo

      # nix
      pkgs.nixpkgs-review

      # Core GUI apps
      pkgs.firefox
      pkgs.google-chrome
      pkgs.kitty
      pkgs.spotify

      # Cloud managment
      pkgs.awscli2
      pkgs.google-cloud-sdk
      pkgs.ssm-session-manager-plugin
      pkgs.terraform

      # Basic shell tools
      pkgs.btop
      pkgs.curl
      pkgs.dnsutils
      pkgs.fend
      pkgs.jq
      pkgs.nvimpager
      pkgs.p7zip
      pkgs.ripgrep
      pkgs.vault
      pkgs.wget

      # Kubernetes
      pkgs.aws-iam-authenticator
      pkgs.glooctl
      pkgs.helmfile
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.sops
      pkgs.stern

      # github
      pkgs.gh

      # Comms
      pkgs.zoom-us
      pkgs.slack
      pkgs.fractal

      #pkgs.dosbox     # Simcity 2000
      #pkgs.frotz      # Zork I
      #pkgs.vitetris   # CLI Tetris
      #pkgs.steam
      #pkgs.somafm-cli
      #pkgs.ncspot
      #pkgs.tuir
    ];
  };
}
