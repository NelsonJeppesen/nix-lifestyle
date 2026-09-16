{ pkgs, ... }: {
  home.packages = [
    pkgs.kafkactl # Kafka CLI
    pkgs.amber-lang # Bash compiler
    pkgs.nixpkgs-review # Nixpkgs PR review
    pkgs.nh # Nix helper
    pkgs.nixfmt # Nix formatter
    # pkgs.vitetris # Terminal tetris clone
    pkgs.lsof # Open files
    pkgs.python313 # Python 3.13 interpreter
    pkgs.circumflex # Hacker News reader
    #pkgs.fx
    #pkgs.somafm-cli # forked
    #pkgs.ansible_2_16
    # pkgs.google-cloud-sdk
    pkgs.awscli2 # AWS CLI v2
    # pkgs.oci-cli # Oracle Cloud Infrastructure CLI
    # pkgs.opentofu # Open-source Terraform fork
    # pkgs.packer # Machine image builder
    pkgs.ssm-session-manager-plugin # AWS SSM sessions
    # pkgs.terraform # Infrastructure as code
    pkgs.tfenv # Terraform version manager
    #pkgs.visidata
    # pkgs.wireshark # Network protocol analyzer
    # pkgs.wireguard-tools # WireGuard VPN management
    # pkgs.fluxcd # GitOps continuous delivery for Kubernetes
    pkgs.k9s # Kubernetes dashboard
    pkgs.jq # JSON processor
    pkgs.jqp # Interactive jq
    pkgs.fastgron # Greppable JSON
    pkgs.yq # YAML processor (jq wrapper for YAML)
    pkgs.yj # Convert between YAML/TOML/JSON/HCL formats
    pkgs.dasel # Query and update JSON/YAML/TOML/XML/CSV
    #pkgs.nvimpager
    #pkgs.terminal-stocks
    pkgs.btop # Resource monitor
    pkgs.choose # Column selector
    pkgs.curl # HTTP client
    pkgs.dnsutils # DNS tools (dig, nslookup, etc.)
    pkgs.fd # Fast find alternative
    pkgs.fend # Arbitrary-precision calculator
    pkgs.gh # GitHub CLI
    pkgs.hurl # HTTP testing tool
    pkgs.ipcalc # IP subnet calculator
    pkgs.nb # Notes
    pkgs.p7zip # 7-Zip archiver
    pkgs.ripgrep # Fast grep alternative
    # pkgs.sd # sed alternative for find-and-replace
    pkgs.vault # HashiCorp Vault secrets management CLI
    pkgs.wget # HTTP/FTP file downloader
    pkgs.whois # Domain/IP WHOIS lookup
    pkgs.wl-clipboard # Wayland clipboard utilities (wl-copy, wl-paste)
    #pkgs.mariadb
    pkgs.kubectl # Kubernetes CLI
    pkgs.k9s # Kubernetes dashboard
    pkgs.kubectx # Quick context and namespace switcher for kubectl
    pkgs.kubernetes-helm # Kubernetes package manager
    pkgs.sops # Encrypted secrets for Kubernetes (Mozilla SOPS)
    pkgs.stern # Multi-pod log tailing for Kubernetes
    pkgs.kubeconform # Kubernetes manifest validation tool
    pkgs.actionlint # GitHub Actions workflow linter
    pkgs.hadolint # Dockerfile best-practices linter
    pkgs.shellcheck # Shell analysis
    pkgs.shfmt # Shell script formatter
    pkgs.yamllint # YAML linter
    pkgs.markdownlint-cli # Markdown linter
  ];
}
