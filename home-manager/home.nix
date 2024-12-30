{
  config,
  lib,
  pkgs,
  users,
  ...
}:
let
  pinnedZoomPkgs =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb.tar.gz";
        sha256 = "0ngw2shvl24swam5pzhcs9hvbwrgzsbcdlhpvzqc7nfk8lc28sp3";
      })
      {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

  pinnedZoom = pinnedZoomPkgs.zoom-us;
in
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    <agenix/modules/age-home.nix>

    ./editorconfig.nix
    ./git.nix
    ./gnome-extensions.nix
    ./gnome.nix
    ./kitty.nix
    ./neovim.nix
    ./zsh.nix
  ];

  programs.home-manager.enable = true;

  fonts.fontconfig.enable = true;

  # Add local scripts
  home.sessionPath = [ "/home/nelson/.local/bin" ];

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

  programs.firefox = {
    enable = true;
    profiles = {
      home = {
        id = 0;
        name = "home";
        # Hide tab bar and side bar header
        userChrome = "\n          #TabsToolbar\n          { visibility: collapse; }\n          #sidebar-box #sidebar-header {\n            display: none !important;\n          }\n        ";
        settings = {
          "gfx.webrender.all" = true;
          "gfx.webrender.enabled" = true;
          "layers.acceleration.force-enabled" = true;
          "layout.css.backdrop-filter.enabled" = true;
          "svg.context-properties.content.enabled" = true;
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
      };
    };
  };

  home = {
    stateVersion = "22.11";
    username = "nelson";
    homeDirectory = "/home/nelson";

    file.".config/aichat/config.yaml".source = ./dotfiles/aichat.yaml;
    file.".config/curlrc".source = ./dotfiles/curlrc;
    file.".config/fend/config.toml".source = ./dotfiles/fend.toml;
    file.".digrc".source = ./dotfiles/digrc;
    file.".local/bin".source = ./bin;
    file.".terraform.d/plugin-cache/.empty".source = ./dotfiles/empty;

    packages = [

      # nixpkgs maintainer
      pkgs.nixpkgs-review

      # fun
      #pkgs.mindustry
      pkgs.vitetris


      pkgs.nerd-fonts.symbols-only

      #pkgs.atkinson-hyperlegible
      #pkgs.maple-mono
      #pkgs.b612
      #pkgs.fira-code
      pkgs.inconsolata
      #pkgs.meslo-lg
      #pkgs.oxygenfonts
      #pkgs.redhat-official-fonts
      #pkgs.roboto-mono
      #pkgs.source-code-pro

      pkgs.google-chrome

      #pkgs.ecapture

      #pkgs.libreoffice
      pkgs.onlyoffice-desktopeditors

      # formater / linter
      pkgs.biome
      pkgs.black
      pkgs.nixfmt-rfc-style
      pkgs.rubocop
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.shfmt
      pkgs.yamlfmt

      # chill
      #pkgs.blanket
      #pkgs.fx
      #pkgs.somafm-cli forked
      pkgs.spotify

      # core GUI apps
      #pkgs.fractal
      #pkgs.google-chrome
      #pkgs.zoom-us
      pinnedZoom
      pkgs.kitty
      pkgs.slack

      # cloud management
      pkgs.ansible_2_16
      pkgs.awscli2
      pkgs.oci-cli
      pkgs.opentofu # terraform fork
      pkgs.packer
      pkgs.ssm-session-manager-plugin
      pkgs.terraform
      pkgs.tflint

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

      # yaml/json tools
      pkgs.jq
      pkgs.fastgron
      pkgs.yq

      # core shell tools
      #pkgs.nvimpager
      #pkgs.terminal-stocks
      pkgs.btop
      pkgs.choose
      pkgs.curl
      pkgs.dnsutils
      pkgs.fd
      pkgs.fend
      #pkgs.gh
      #pkgs.gh-dash
      pkgs.hurl
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

      pkgs.mariadb

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
