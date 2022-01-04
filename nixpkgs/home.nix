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

     packages = [
      # Browser
      pkgs.google-chrome      # Helpful for --app mode
      pkgs.firefox

      # Terminals
      #pkgs.cool-retro-term    # play
      pkgs.kitty              # work
      pkgs.nvimpager

      # DevOps
      pkgs.aws-iam-authenticator
      pkgs.awscli2
      pkgs.curl
      pkgs.dnsutils
      pkgs.googler
      pkgs.helmfile
      pkgs.jq
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.ripgrep
      pkgs.slack
      pkgs.sops
      pkgs.ssm-session-manager-plugin
      pkgs.terraform
      pkgs.terraform-docs
      pkgs.p7zip
      pkgs.wget
      pkgs.vault

      # Work
      pkgs.zoom-us

      # Games
      #pkgs.dosbox     # Simcity 2000
      #pkgs.frotz      # Zork I
      #pkgs.vitetris   # CLI Tetris
      #pkgs.steam

      # Music
      #pkgs.somafm-cli
      #pkgs.ncspot
      pkgs.spotify

      # Reddit
      #pkgs.tuir
    ];
  };
}
