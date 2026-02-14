# home.nix - Main home-manager module
#
# Central configuration that imports all other modules and defines:
# - User identity and home directory
# - XDG user directories
# - Agenix-managed secrets (envrc, AWS credentials, kubeconfig)
# - System-wide packages organized by category
# - Dotfile symlinks into the home directory
{ config, pkgs, ... }:
{
  # Allow installation of proprietary packages (Chrome, 1Password, Zoom, etc.)
  nixpkgs.config.allowUnfree = true;

  # Import all per-application/concern modules
  imports = [
    ./chrome-apps.nix # Chrome PWA wrappers (Slack, ChatGPT)
    ./editorconfig.nix # Global editorconfig settings
    ./firefox.nix # Firefox browser with custom search engines
    ./git.nix # Git config, signing, aliases, difftastic
    ./gnome-extensions.nix # GNOME Shell extensions and their settings
    ./gnome.nix # GNOME desktop dconf settings and keybindings
    ./kitty.nix # Kitty terminal emulator
    ./mcp.nix # Model Context Protocol servers for AI tools
    ./neovim.nix # Neovim editor with LSP, plugins, and keymaps
    ./opencode.nix # OpenCode AI coding assistant
    ./zsh.nix # Zsh shell, prompt, aliases, and functions
  ];

  # XDG user directories (Desktop, Documents, etc.)
  # Only enable the ones actually used; others are commented out
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    download = "${config.home.homeDirectory}/Downloads";
    # documents = "${config.home.homeDirectory}/Documents";
    # music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    # videos = "${config.home.homeDirectory}/Videos";
    # publicShare = "${config.home.homeDirectory}/Public";
    # templates = "${config.home.homeDirectory}/Templates";
    # desktop = "${config.home.homeDirectory}/Desktop";
  };

  # Let home-manager manage itself (enables the `home-manager` CLI)
  programs.home-manager.enable = true;

  # Enable fontconfig so user-installed fonts are discoverable
  fonts.fontconfig.enable = true;

  # Add ~/.local/bin to PATH for user scripts (update, n, etc.)
  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  # Agenix-managed secrets: encrypted at rest, decrypted on activation
  # Source files live in /etc/secrets/encrypted/ (managed by NixOS config)
  age.secrets = {
    # direnv .envrc for personal projects (API keys, tokens, etc.)
    "envrc_personal" = {
      file = /etc/secrets/encrypted/envrc.personal.age;
      path = "/home/nelson/source/personal/.envrc";
    };

    # AWS credentials for personal account
    "awscredentials.personal" = {
      file = "/etc/secrets/encrypted/awscredentials.personal.age";
      path = "/home/nelson/source/personal/.aws/credentials";
    };

    # Kubernetes config (decrypted to .orig so it can be copied and modified
    # for context switching without overwriting the managed file)
    "kubeconfig.personal" = {
      file = /etc/secrets/encrypted/kubeconfig.personal.age;
      path = "/home/nelson/source/personal/.kube/config.orig";
    };

    # direnv .envrc for the root source directory
    "envrc_root" = {
      file = /etc/secrets/encrypted/envrc.root.age;
      path = "/home/nelson/source/.envrc";
    };
  };

  home = {
    # NixOS/home-manager state version -- do not change without migration
    stateVersion = "26.05";
    username = "nelson";
    homeDirectory = "/home/nelson";

    # ── Dotfile symlinks ──────────────────────────────────────────────
    # These map static config files from ./dotfiles/ into the home directory
    file.".config/aichat/config.yaml".source = ./dotfiles/aichat.yaml; # aichat CLI config
    file.".config/curlrc".source = ./dotfiles/curlrc; # curl defaults (--no-progress-meter)
    file.".config/fend/config.toml".source = ./dotfiles/fend.toml; # fend calculator config
    file.".digrc".source = ./dotfiles/digrc; # dig defaults (+noall +answer)
    file.".local/bin/update".source = ./dotfiles/update; # System update script
    file.".local/bin/n".source = ./dotfiles/n; # Quick notes launcher (fzf + nb)
    file.".terraform.d/plugin-cache/.empty".source = ./dotfiles/empty; # Ensure terraform plugin cache dir exists

    # ── Packages ──────────────────────────────────────────────────────
    packages = [

      # ── Nixpkgs maintainer tools ───────────────────────────────────
      pkgs.nixpkgs-review # Review tool for nixpkgs pull requests

      # ── Games ───────────────────────────────────────────────────────
      #pkgs.mindustry
      pkgs.vitetris # Terminal tetris clone

      # ── Fonts ───────────────────────────────────────────────────────
      # Nerd Font symbols only (used by kitty symbol_map for icon rendering)
      pkgs.nerd-fonts.symbols-only

      pkgs.lsof # List open files (debugging network ports, etc.)

      # Fonts to try -- uncomment to test different coding fonts
      #pkgs.atkinson-hyperlegible
      #pkgs.maple-mono
      pkgs.python313 # Python 3.13 interpreter
      pkgs.atkinson-monolegible # High-legibility monospace font
      #pkgs.b612
      #pkgs.fira-code
      pkgs.inconsolata # Classic monospace font
      #pkgs.meslo-lg
      #pkgs.oxygenfonts
      #pkgs.redhat-official-fonts
      #pkgs.roboto-mono
      #pkgs.source-code-pro

      # ── GUI applications ────────────────────────────────────────────
      pkgs.google-chrome # Web browser (also used by chrome-apps.nix PWAs)
      pkgs._1password-gui # Password manager

      #pkgs.ecapture # eBPF-based TLS capture tool

      #pkgs.libreoffice
      pkgs.onlyoffice-desktopeditors # Office suite (Microsoft-compatible)

      # ── Music and media ─────────────────────────────────────────────
      #pkgs.fx
      #pkgs.somafm-cli # forked
      pkgs.spotify # Music streaming

      # ── Core GUI apps ───────────────────────────────────────────────
      #pkgs.fractal # Matrix chat client
      #pkgs.google-chrome
      pkgs.zoom-us # Video conferencing
      #pinnedZoom
      pkgs.kitty # Terminal emulator (configured in kitty.nix)
      # pkgs.slack # Using Chrome PWA wrapper instead (see chrome-apps.nix)

      # ── Cloud and infrastructure tools ──────────────────────────────
      #pkgs.ansible_2_16
      pkgs.awscli2 # AWS CLI v2
      pkgs.oci-cli # Oracle Cloud Infrastructure CLI
      pkgs.opentofu # Open-source Terraform fork
      pkgs.packer # Machine image builder
      pkgs.ssm-session-manager-plugin # AWS Systems Manager session plugin
      pkgs.terraform # Infrastructure as code

      pkgs.codex
      pkgs.telegram-desktop

      # "A terminal spreadsheet multitool for discovering and arranging data"
      #pkgs.visidata

      # ── Development dependencies ────────────────────────────────────
      # sqlite is required by several nvim plugins (e.g. smart-open, frecency)
      pkgs.sqlite

      # Dependencies for the GNOME Quick Lofi extension (internet radio player)
      pkgs.socat # Multipurpose relay (used for mpv IPC)
      pkgs.mpv # Media player (backend for Quick Lofi)

      pkgs.wireshark # Network protocol analyzer

      # ── Networking tools ────────────────────────────────────────────
      pkgs.wireguard-tools # WireGuard VPN management

      # ── Kubernetes tools ────────────────────────────────────────────
      # pkgs.fluxcd # GitOps continuous delivery for Kubernetes
      pkgs.k9s # Terminal UI for Kubernetes clusters

      # ── YAML/JSON/TOML data tools ──────────────────────────────────
      pkgs.jq # JSON processor
      pkgs.jqp # Interactive jq playground with live preview
      pkgs.fastgron # Make JSON greppable (fast gron reimplementation)
      pkgs.yq # YAML processor (jq wrapper for YAML)
      pkgs.yj # Convert between YAML/TOML/JSON/HCL formats
      pkgs.dasel # Query and update JSON/YAML/TOML/XML/CSV

      # ── Core shell utilities ────────────────────────────────────────
      #pkgs.nvimpager
      #pkgs.terminal-stocks
      pkgs.btop # Resource monitor (better top)
      pkgs.choose # Cut alternative with a friendlier interface
      #pkgs.codex
      pkgs.curl # HTTP client
      pkgs.dnsutils # DNS tools (dig, nslookup, etc.)
      pkgs.fd # Fast find alternative
      pkgs.fend # Arbitrary-precision calculator
      pkgs.gh # GitHub CLI
      pkgs.gh-dash # GitHub CLI dashboard extension
      #pkgs.hurl # HTTP testing tool
      pkgs.ipcalc # IP subnet calculator
      pkgs.jira-cli-go # Jira CLI client
      pkgs.nb # Note-taking and knowledge base CLI
      pkgs.p7zip # 7-Zip archiver
      pkgs.ripgrep # Fast grep alternative
      pkgs.sd # sed alternative for find-and-replace
      pkgs.vault # HashiCorp Vault secrets management CLI
      pkgs.wget # HTTP/FTP file downloader
      pkgs.whois # Domain/IP WHOIS lookup
      pkgs.wl-clipboard # Wayland clipboard utilities (wl-copy, wl-paste)

      #pkgs.mariadb

      # ── Kubernetes ecosystem ────────────────────────────────────────
      #pkgs.glooctl
      pkgs.helmfile # Declarative Helm chart deployments
      pkgs.kubectl # Kubernetes CLI
      pkgs.kubectx # Quick context and namespace switcher for kubectl
      pkgs.kubernetes-helm # Kubernetes package manager
      pkgs.sops # Encrypted secrets for Kubernetes (Mozilla SOPS)
      pkgs.stern # Multi-pod log tailing for Kubernetes
      pkgs.kubeconform # Kubernetes manifest validation tool

      # ── Linting and formatting tools ────────────────────────────────
      pkgs.actionlint # GitHub Actions workflow linter
      pkgs.hadolint # Dockerfile best-practices linter
      pkgs.shellcheck # Shell script static analysis tool
      pkgs.shfmt # Shell script formatter
      pkgs.yamllint # YAML linter
      pkgs.markdownlint-cli # Markdown linter and style checker

      # ── Data transformation tools ───────────────────────────────────
      pkgs.dasel # Query and update structured data (JSON/YAML/TOML/XML/CSV)
      pkgs.yj # Convert between YAML/TOML/JSON/HCL formats
    ];
  };
}
