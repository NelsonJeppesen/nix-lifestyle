{
  config,
  lib,
  pkgs,
  users,
  ...
}:
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

    file.".config/curlrc".source = ./dotfiles/curlrc;
    file.".config/fend/config.toml".source = ./dotfiles/fend.toml;
    file.".local/bin".source = ./bin;
    file.".terraform.d/plugin-cache/.empty".source = ./dotfiles/empty;

    packages = [

      # nixpkgs maintainer
      pkgs.nixpkgs-review

      # fun
      #pkgs.mindustry
      pkgs.vitetris

      (pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; })
      pkgs.b612
      pkgs.atkinson-hyperlegible
      pkgs.redhat-official-fonts
      pkgs.source-code-pro
      #pkgs.meslo-lg
      #pkgs.roboto-mono

      # formaters
      pkgs.biome
      pkgs.nixfmt-rfc-style
      pkgs.shfmt

      #pkgs.gpxsee-qt6

      # chill
      #pkgs.somafm-cli forked
      pkgs.spotify
      pkgs.blanket
      pkgs.fx

      # core GUI apps
      #pkgs.fractal
      #pkgs.google-chrome
      pkgs.kitty
      pkgs.slack
      pkgs.zoom-us

      # cloud management
      pkgs.awscli2
      pkgs.opentofu # terraform fork
      pkgs.postman
      pkgs.ssm-session-manager-plugin
      pkgs.terraform
      pkgs.tflint

      # better shell scripts
      pkgs.shellcheck
      pkgs.shfmt

      pkgs.yamlfmt

      # used by nvim plugins
      pkgs.sqlite

      # used by gnome-extension `quick lofi`
      pkgs.socat
      pkgs.mpv

      # try out gpt
      pkgs.chatblade
      pkgs.chatgpt-cli

      # yaml/json tools
      pkgs.jq
      pkgs.fastgron
      pkgs.yq

      # core shell tools
      #pkgs.terminal-stocks
      pkgs.btop
      pkgs.choose
      pkgs.curl
      pkgs.dnsutils
      pkgs.fd
      pkgs.fend
      pkgs.gh
      pkgs.gh-dash
      pkgs.ipcalc
      pkgs.nb
      #pkgs.nvimpager
      pkgs.p7zip
      pkgs.ripgrep
      pkgs.sd
      pkgs.vault
      pkgs.walk
      pkgs.wget
      pkgs.whois
      pkgs.wl-clipboard

      # Kubernetes
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
