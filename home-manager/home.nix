{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  # programs.kubecolor.enable = true;
  programs.fabric-ai.enable = true;

  imports = [
    <agenix/modules/age-home.nix>

    ./chrome-apps.nix
    ./editorconfig.nix
    ./firefox.nix
    ./git.nix
    ./gnome-extensions.nix
    ./gnome.nix
    ./kitty.nix
    ./mcp.nix
    ./neovim.nix
    ./opencode.nix
    ./zsh.nix
  ];

xdg.userDirs = {
  enable = true;
  createDirectories = true;

  # set your dirs explicitly
  download = "${config.home.homeDirectory}/Downloads";
  # documents = "${config.home.homeDirectory}/Documents";
  # music = "${config.home.homeDirectory}/Music";
  pictures = "${config.home.homeDirectory}/Pictures";
  # videos = "${config.home.homeDirectory}/Videos";
  # publicShare = "${config.home.homeDirectory}/Public";
  # templates = "${config.home.homeDirectory}/Templates";
  # desktop = "${config.home.homeDirectory}/Desktop";
};

  programs.home-manager.enable = true;


  fonts.fontconfig.enable = true;

  # Add local scripts
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  age.secrets = {
    "envrc_personal" = {
      file = /etc/secrets/encrypted/envrc.personal.age;
      path = "/home/nelson/source/personal/.envrc";
    };
    "awscredentials.personal" = {
      file = "/etc/secrets/encrypted/awscredentials.personal.age";
      path = "/home/nelson/source/personal/.aws/credentials";
    };
    # manually copy this file so I can change context
    "kubeconfig.personal" = {
      file = /etc/secrets/encrypted/kubeconfig.personal.age;
      path = "/home/nelson/source/personal/.kube/config.orig";
    };
    "envrc_root" = {
      file = /etc/secrets/encrypted/envrc.root.age;
      path = "/home/nelson/source/.envrc";
    };

  };

  home = {
    # bumped from 22.11 -> 24.05; review release notes before locking in
    stateVersion = "24.05";
    username = "nelson";
    homeDirectory = "/home/nelson";

    file.".config/aichat/config.yaml".source = ./dotfiles/aichat.yaml;
    file.".config/curlrc".source = ./dotfiles/curlrc;
    file.".config/fend/config.toml".source = ./dotfiles/fend.toml;
    file.".digrc".source = ./dotfiles/digrc;
    file.".local/bin/update".source = ./dotfiles/update;
    file.".local/bin/n".source = ./dotfiles/n;
    file.".terraform.d/plugin-cache/.empty".source = ./dotfiles/empty;

    packages = [

      # nixpkgs maintainer
      pkgs.nixpkgs-review

      # fun
      #pkgs.mindustry
      pkgs.vitetris

      pkgs.nerd-fonts.symbols-only

      pkgs.lsof

      #pkgs.atkinson-hyperlegible
      #pkgs.maple-mono
      pkgs.python313
      pkgs.atkinson-monolegible
      #pkgs.b612
      #pkgs.fira-code
      pkgs.inconsolata
      #pkgs.meslo-lg
      #pkgs.oxygenfonts
      #pkgs.redhat-official-fonts
      #pkgs.roboto-mono
      #pkgs.source-code-pro

      pkgs.google-chrome
      pkgs._1password-gui

      #pkgs.ecapture

      #pkgs.libreoffice
      pkgs.onlyoffice-desktopeditors

      # chill
      #pkgs.fx
      #pkgs.somafm-cli forked
      pkgs.spotify

      # core GUI apps
      #pkgs.fractal
      #pkgs.google-chrome
      pkgs.zoom-us
      #pinnedZoom
      pkgs.kitty
      # pkgs.slack

      # cloud management
      #pkgs.ansible_2_16
      pkgs.awscli2
      pkgs.oci-cli
      pkgs.opentofu # terraform fork
      pkgs.packer
      pkgs.ssm-session-manager-plugin
      pkgs.terraform

      # "A terminal spreadsheet multitool for discovering and arranging data"
      #pkgs.visidata

      # code
      # used by nvim plugins
      pkgs.sqlite

      # used by gnome-extension `quick lofi`
      pkgs.socat
      pkgs.mpv

      pkgs.wireshark

      # try out gpt
      pkgs.aichat
      #pkgs.chatgpt-cli
      #pkgs.shell-gpt

      pkgs.wireguard-tools
      pkgs.fluxcd
      pkgs.k9s

      # yaml/json tools
      pkgs.jq
      pkgs.jqp
      pkgs.fastgron
      pkgs.yq

      # core shell tools
      #pkgs.nvimpager
      #pkgs.terminal-stocks
      pkgs.btop
      pkgs.choose
      #pkgs.codex
      pkgs.curl
      pkgs.dnsutils
      pkgs.fd
      pkgs.fend
      pkgs.gh
      pkgs.gh-dash
      #pkgs.hurl
      pkgs.ipcalc
      pkgs.jira-cli-go
      pkgs.nb
      pkgs.p7zip
      pkgs.ripgrep
      pkgs.sd
      pkgs.vault
      pkgs.walk
      pkgs.wget
      pkgs.whois
      pkgs.wl-clipboard

      #pkgs.mariadb

      # Kubernetes
      #pkgs.glooctl
      pkgs.helmfile
      pkgs.kubectl
      pkgs.kubectx
      pkgs.kubernetes-helm
      pkgs.sops
      pkgs.stern
    ];
  };
}
