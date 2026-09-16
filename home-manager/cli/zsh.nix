{ config, pkgs, ... }:
let
  # Package shell helpers with runtime dependencies.
  nsr = pkgs.writeShellApplication {
    name = "nsr";
    text = builtins.readFile ./bin/nsr;
    runtimeInputs = [ pkgs.nix ];
  };

  rgreplace = pkgs.writeShellApplication {
    name = "rgreplace";
    text = builtins.readFile ./bin/rgreplace;
    runtimeInputs = [
      pkgs.ripgrep
      pkgs.findutils
      pkgs.sd
    ];
  };

  openGitFiles = pkgs.writeShellApplication {
    name = "open-git-files";
    runtimeInputs = [
      pkgs.git
      config.programs.nvf.finalPackage
    ];
    text = ''
      mode="''${1:-}"
      root="$(git rev-parse --show-toplevel)" || exit
      cd "$root"

      declare -a files=()
      declare -A seen=()
      add_files() {
        local path
        while IFS= read -r -d "" path; do
          if [[ -f "$path" && -z "''${seen[$path]:-}" ]]; then
            files+=("$path")
            seen["$path"]=1
          fi
        done
      }

      case "$mode" in
        unstaged)
          add_files < <(git diff --name-only -z --diff-filter=ACMRTUXB --)
          ;;
        main)
          git rev-parse --verify --quiet main >/dev/null || {
            printf 'open-git-files: branch main does not exist\n' >&2
            exit 1
          }
          add_files < <(git diff --name-only -z --diff-filter=ACMRTUXB main --)
          ;;
        *)
          printf 'usage: open-git-files unstaged|main\n' >&2
          exit 2
          ;;
      esac

      # Untracked files are unstaged and are absent from `git diff`.
      add_files < <(git ls-files --others --exclude-standard -z)

      if (( ''${#files[@]} == 0 )); then
        printf 'No matching files.\n'
        exit
      fi
      exec nvim -- "''${files[@]}"
    '';
  };
in
{
  # Make the built scripts available on PATH for interactive use.
  home.packages = [
    nsr
    openGitFiles
    rgreplace
  ];

  programs = {
    # direnv: automatically load/unload .envrc environment variables per directory
    direnv.enable = true;

    # fzf: fuzzy finder used throughout the shell (history, file picker, etc.)
    fzf = {
      enable = true;
      defaultOptions = [
        "--layout=reverse" # Show results top-to-bottom (feels more natural)
      ];
      # Let Atuin handle Ctrl-R.
      historyWidget.command = "";
    };

    # Synced shell history.
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ]; # Don't hijack up-arrow (use Ctrl+R instead)

      settings = {
        filter_mode = "workspace"; # Filter history by current git repo/directory
        keymap_mode = "emacs"; # Use emacs-style keybindings in search UI
        search_mode = "fulltext"; # Full-text search across command history
        secrets_filter = true; # Automatically filter out commands containing secrets
        show_preview = true; # Show command preview in search results
        sync_address = "http://192.168.5.0:8888"; # Self-hosted Atuin sync server on LAN
        update_check = false;
        workspaces = true;
      };
    };

    # Shell prompt.
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Disable noisy/unhelpful prompt modules
        cmd_duration.disabled = true;
        helm.disabled = true;
        python.disabled = true;
        terraform.disabled = true;

        # Catppuccin Mocha prompt palette
        palette = "catppuccin_mocha";
        palettes.catppuccin_mocha = {
          rosewater = "#f5e0dc";
          flamingo = "#f2cdcd";
          pink = "#f5c2e7";
          mauve = "#cba6f7";
          red = "#f38ba8";
          maroon = "#eba0ac";
          peach = "#fab387";
          yellow = "#f9e2af";
          green = "#a6e3a1";
          teal = "#94e2d5";
          sky = "#89dceb";
          sapphire = "#74c7ec";
          blue = "#89b4fa";
          lavender = "#b4befe";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
        };

        # Fill character between left and right prompt sections
        fill = {
          symbol = " ";
        };

        # Explicit prompt modules.
        format = "$username$hostname$aws$nix_shell$cmd_duration$fill$kubernetes$line_break$directory$git_branch$git_status$character";

        # Directory display: show up to 9 levels, highlight repo root
        directory = {
          truncation_length = 9;
          repo_root_style = "bright-yellow";
        };

        # Git status indicators (modified, staged, ahead/behind)
        git_status = {
          format = "([\\[$all_status$ahead_behind\\]]($style)) ";
        };

        # Git branch display format
        git_branch = {
          format = "\\[[$branch(:$remote_branch)]($style)\\] ";
        };

        # AWS profile and region display with short region aliases
        aws = {
          format = "\\[[$profile]($style) $region $duration\\]";
          region_aliases = {
            ap-southeast-2 = "apse2";
            ca-central-1 = "cac1";
            eu-central-1 = "euc1";
            us-east-1 = "use1";
            us-east-2 = "use2";
            us-west-1 = "usw1";
            us-west-2 = "usw2";
          };
        };

        # Kubernetes context; shorten EKS names.
        kubernetes = {
          disabled = false;
          format = "\\[$namespace [$context]($style)\\]";
          contexts = [
            {
              context_pattern = "arn:aws:eks:(?P<aws>.*)cluster/(?P<cluster>.*)";
              context_alias = "$aws$cluster";
            }
          ];
        };
      };
    };

    zsh = {
      enable = true;

      # Zsh plugins (loaded via home-manager's plugin system)
      plugins = [
        # fzf-tab: replace zsh's default tab completion with fzf-powered fuzzy matching
        {
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
        }
      ];

      autosuggestion.enable = true; # Fish-like autosuggestions based on history
      defaultKeymap = "emacs"; # Emacs-style line editing (Ctrl+A/E, etc.)
      enableCompletion = true; # Enable zsh completion system
      syntaxHighlighting.enable = true; # Real-time syntax highlighting as you type

      # Environment variables set for every zsh session
      sessionVariables = {
        DIRENV_LOG_FORMAT = ""; # Silence direnv "loading .envrc" messages
        MANPAGER = "nvim +Man!";
        NIXPKGS_ALLOW_UNFREE = "1"; # Allow unfree packages in nix-shell
        TFENV_CONFIG_DIR = "$HOME/.cache/tfenv"; # dont write to readonly nix store
      };

      #  Shell aliases
      shellAliases = {

        okta-awscli = "UV_NO_SYNC=1 uvx okta-awscli";
        nless = "uvx --from nothing-less  nless";

        # System
        reboot-bios = "systemctl reboot --firmware-setup"; # Reboot directly into UEFI/BIOS

        # AWS
        al = "aws sso login"; # Quick SSO login

        # Clipboard (Wayland-only via wl-clipboard)
        cbc = "${pkgs.wl-clipboard}/bin/wl-copy"; # Pipe to clipboard
        cbp = "${pkgs.wl-clipboard}/bin/wl-paste"; # Paste from clipboard

        # Git
        g = "${pkgs.git}/bin/git";
        cdr = "cd \"$(${pkgs.git}/bin/git rev-parse --show-toplevel)\""; # cd to git repo root
        vu = "open-git-files unstaged"; # Open unstaged and untracked files in Neovim
        vm = "open-git-files main"; # Open files changed relative to local main

        ws = "herdr workspace create --cwd ~/source";

        # direnv
        da = "direnv allow"; # Quick allow for .envrc changes

        # Notes (nb-based note-taking)
        nw = "nb edit work-$(date +%Y-%m).md      2>/dev/null || nb add --title work-$(date +%Y-%m)"; # Work notes (monthly)
        np = "nb edit personal-$(date +%Y-%m).md  2>/dev/null || nb add --title personal-$(date +%Y-%m)"; # Personal notes (monthly)
        ns = "$EDITOR $(mktemp --suffix=.md)"; # Scratch markdown note in temp file

        # Calculator (fend)
        f = "fend";
        fc = "clear;fend";

        # Terraform
        t = "terraform";
        ta = "terraform apply";
        ti = "terraform init";
        tp = "terraform plan";
        tpv = "terraform plan -no-color | nvim -"; # Plan output in nvim for review
        tpwb = "terraform plan -no-color | grep 'will be'"; # Quick summary of what will change

        # Kubernetes aliases
        k = "kubectl";
        kns = "kubens"; # Quick namespace switch
        uc = "kubectx"; # Quick context switch
        ucu = "kubectx --unset"; # Unset current context
      };

      #  Shell init (large blob; kept last per AGENTS.md "module structure")
      initContent = ''
        # Shell titles for Kitty and herdr.
        # Zsh-native batch rename.
        autoload -Uz zmv
        alias zmv='noglob zmv'

        source ~/.config/zsh/named-dirs.zsh


        ap() {
          local query="$1"
          local profile
          mkdir -p ~/.aws
          profile="$(${pkgs.awscli2}/bin/aws configure list-profiles | sort | ${pkgs.fzf}/bin/fzf --exact --query="$query" --select-1)" || return
          if [ -n "$profile" ]; then
            print -r -- "export AWS_PROFILE=''${(q)profile}" > ~/.aws/sticky.profile
            source ~/.aws/sticky.profile
          fi
        }

        # Select and persist an AWS region.
        ar() {
          local query="$1"
          local region
          mkdir -p ~/.aws
          region="$(printf '%s\n' us-east-1 ca-central-1 eu-central-1 ap-southeast-2 | ${pkgs.fzf}/bin/fzf --exact --query="$query" --select-1)" || return
          if [ -n "$region" ]; then
            print -r -- "export AWS_REGION=''${(q)region}" > ~/.aws/sticky.region
            source ~/.aws/sticky.region
          fi
        }

        # Run commands in herdr tabs.
        # _herdr_new_tab: create a tab and run "$@" in it.
        # $1 = "focus" | "no-focus"; remaining args = command to run.
        _herdr_new_tab() {
          local focus_flag="$1"; shift
          if (( $# == 0 )); then
            echo "usage: ''${funcstack[2]} COMMAND [ARGS...]" >&2
            return 1
          fi
          if [[ "''${HERDR_ENV:-}" != 1 ]]; then
            echo "herdr: requires HERDR_ENV=1" >&2
            return 1
          fi
          local response workspace_id pane_id
          # A moved pane keeps its launch-time environment; resolve live context.
          response="$(herdr pane current --current)" || return
          workspace_id="$(${pkgs.jq}/bin/jq -er \
            '.result.pane.workspace_id | select(type == "string" and length > 0)' \
            <<< "$response")" || return
          response="$(herdr tab create --workspace "$workspace_id" \
            --cwd "$PWD" --"$focus_flag")" || return
          pane_id="$(${pkgs.jq}/bin/jq -er \
            '.result.root_pane.pane_id | select(type == "string" and length > 0)' \
            <<< "$response")" || {
            echo "herdr: could not determine new pane id" >&2
            return 1
          }
          local command="''${(j: :)''${(q)@}}"
          herdr pane run "$pane_id" "$command"
        }

        # hrf: launch a command in a new tab and focus it.
        hrf() { _herdr_new_tab focus "$@"; }

        # hrn: launch a command in a new tab without focusing it.
        hrn() { _herdr_new_tab no-focus "$@"; }

        # Terraform state helpers preserve selected resource addresses.
        tss() {
          local address
          address="$(terraform state list | ${pkgs.fzf}/bin/fzf)" || return
          terraform state show "$address"
        }

        tsd() {
          local -a addresses
          addresses=(''${(f)"$(terraform state list | ${pkgs.fzf}/bin/fzf --multi)"}) || return
          (( ''${#addresses} )) || return
          printf 'Remove %d object(s) from state? [y/N] ' "''${#addresses}"
          read -r reply
          [[ "$reply" == [yY] ]] || return
          terraform state rm "''${addresses[@]}"
        }

        tt() {
          local -a addresses replace_args
          addresses=(''${(f)"$(terraform state list | ${pkgs.fzf}/bin/fzf --multi)"}) || return
          (( ''${#addresses} )) || return
          local address
          for address in "''${addresses[@]}"; do
            replace_args+=("-replace=$address")
          done
          terraform apply "''${replace_args[@]}"
        }

        # rst: reset shell environment -- clear AWS/kube context, return to ~/source.
        rst() {
          cd ~/source || return
          ${pkgs.kubectx}/bin/kubectx --unset
          mkdir -p ~/.aws
          : > ~/.aws/sticky.profile
          : > ~/.aws/sticky.region
          unset AWS_PROFILE AWS_REGION
          clear
        }

        # curl-all-ips: curl every A/AAAA record behind a DNS name individually.
        curl-all-ips() {
          local host="$1" path="''${2:-/}" port="''${3:-443}"
          if [[ -z "$host" ]]; then
            echo "usage: curl-all-ips HOST [PATH] [PORT]" >&2
            return 1
          fi
          # Strip any scheme/path the user may have pasted into HOST.
          host="''${host#https://}"
          host="''${host#http://}"
          host="''${host%%/*}"
          [[ "$path" = /* ]] || path="/$path"

          local -a ips
          ips=(''${(f)"$(${pkgs.dnsutils}/bin/dig +short A "$host"; ${pkgs.dnsutils}/bin/dig +short AAAA "$host")"})
          if (( ''${#ips} == 0 )); then
            echo "curl-all-ips: no A/AAAA records for $host" >&2
            return 1
          fi

          echo "$host -> ''${#ips} IP(s) on :$port$path"
          local ip
          for ip in "''${ips[@]}"; do
            printf '%-39s ' "$ip"
            ${pkgs.curl}/bin/curl \
              --silent --show-error --output /dev/null \
              --max-time 10 \
              --resolve "$host:$port:$ip" \
              --write-out 'status=%{http_code} time=%{time_total}s\n' \
              "https://$host:$port$path" \
              || echo "request failed"
          done
        }
      '';
    };
  };
}
