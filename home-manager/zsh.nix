# zsh.nix - Zsh shell configuration
#
# Configures the Z shell with:
# - direnv integration for per-directory environment variables
# - fzf for fuzzy finding (files, history, completions)
# - Atuin for shell history sync (syncs to local server at 192.168.5.0)
# - Starship cross-shell prompt with Kubernetes context and AWS profile display
# - fzf-tab plugin for tab completion with fuzzy matching
# - Custom functions:
#     ap  -- AWS profile switcher (mutates current shell)
#     ar  -- AWS region switcher (mutates current shell)
#     rst -- reset env (mutates current shell)
#     wt  -- jump to a git worktree (inline; uses lazyworktree functions)
#     hrf -- run a command in a new herdr tab, focusing it
#     hrn -- run a command in a new herdr tab without focusing it
#     curl-all-ips -- curl every A/AAAA record behind a DNS name (per-IP)
#     nsr, rgreplace -- packaged via writeShellApplication
#     (gets shellcheck + PATH wrapping). See ./bin/.
# - Extensive shell aliases for terraform, kubectl, git, clipboard, and notes
# - Kitty terminal tab title integration (shows PWD and running command)
{ pkgs, ... }:
let
  # Build small CLIs from ./bin/* using writeShellApplication so each script
  # is shellcheck-validated at build time and has its runtime deps on PATH.
  # Functions that need to mutate the *current* shell (cd, source, unset
  # AWS_PROFILE, jump to a worktree) stay inline in initContent below.
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
      pkgs.gnused
    ];
  };
in
{
  # Make the built scripts available on PATH for interactive use.
  home.packages = [
    nsr
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
      # Yield Ctrl-R to Atuin (below). Both fzf and Atuin bind Ctrl-R for
      # zsh; an empty command is home-manager's supported way to disable
      # fzf's history widget so the history manager owns Ctrl-R. fzf keeps
      # Ctrl-T (files) and Alt-C (cd). See programs.atuin.flags comment.
      historyWidget.command = "";
    };

    # Atuin: replacement shell history that syncs across machines
    # Stores history in SQLite and syncs to a self-hosted server on the LAN
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
      };
    };

    # Starship: minimal, fast, cross-shell prompt
    # Displays git status, AWS profile/region, Kubernetes context, and directory
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Disable noisy/unhelpful prompt modules
        cmd_duration.disabled = true;
        helm.disabled = true;
        python.disabled = true;
        terraform.disabled = true;

        # Catppuccin Mocha palette (matches kitty's Catppuccin theme pair)
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

        # Custom prompt layout. NOTE: $all is intentionally NOT used; it
        # would re-render every module already listed below (kubernetes,
        # git_branch, git_status, directory, battery, time, ...).
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

        # Kubernetes context display: show namespace and cluster name
        # Strips the verbose ARN prefix from EKS cluster names
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
        MANPAGER = "vim +Man!"; # Use vim as the man page viewer
        NIXPKGS_ALLOW_UNFREE = "1"; # Allow unfree packages in nix-shell
        TFENV_CONFIG_DIR = "$HOME/.cache/tfenv"; # dont write to readonly nix store
      };

      # ── Shell aliases ─────────────────────────────────────────────
      shellAliases = {

        okta-awscli = "uvx okta-awscli";
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

        # direnv
        da = "direnv allow"; # Quick allow for .envrc changes

        # Notes (nb-based note-taking)
        nw = "nb edit work-$(date +%Y-%m).md      2>/dev/null || nb add --title work-$(date +%Y-%m)"; # Work notes (monthly)
        np = "nb edit personal-$(date +%Y-%m).md  2>/dev/null || nb add --title personal-$(date +%Y-%m)"; # Personal notes (monthly)
        ns = "$EDITOR $(mktemp --suffix=.md)"; # Scratch markdown note in temp file

        # Calculator (fend)
        f = "fend";
        fc = "clear;fend";

        # Terraform aliases (short commands for daily IaC work)
        t = "terraform";
        ta = "terraform apply";
        ti = "terraform init";
        tp = "terraform plan";
        tpv = "terraform plan -no-color | nvim -"; # Plan output in nvim for review
        tpwb = "terraform plan -no-color | grep 'will be'"; # Quick summary of what will change
        tsd = "echo $(terraform state list|fzf --multi)|xargs -n1 terraform state rm"; # Fuzzy state remove
        tss = "terraform state show $(terraform state list|fzf)"; # Fuzzy state show
        tt = "echo $(terraform state list|fzf --multi)|xargs -n1 terraform taint"; # Fuzzy taint

        # Kubernetes aliases
        k = "kubectl";
        kns = "kubens"; # Quick namespace switch
        uc = "kubectx"; # Quick context switch
        ucu = "kubectx --unset"; # Unset current context
      };

      # ── Shell init (large blob; kept last per AGENTS.md "module structure") ──
      initContent = ''
        # Tab/title management is handled by kitty's shell integration
        # (programs.kitty.shellIntegration.enableZshIntegration in kitty.nix);
        # avoid duplicate OSC1/OSC2 escapes here.

        # ── Auto-cd to source directory on new terminal ─────────────
        # If opening a new terminal (not over SSH), cd to ~/source and clear
        if [[ "$TERM" != "linux" && "$(pwd)" = "$HOME" && -z "$SSH_CLIENT" ]]; then
          cd ~/source
          clear
        fi

        # ── Custom shell functions ──────────────────────────────────
        # These mutate the *current* shell (cd, source, unset env) so they
        # cannot be packaged as standalone binaries; the heavier scripts
        # (nsr, wt, rgreplace) live in ./bin/* and are built via
        # pkgs.writeShellApplication for shellcheck coverage.

        # ap: AWS Profile switcher
        # Usage: ap [query] -- fuzzy-select an AWS profile and export it
        # Persists selection to ~/.aws/sticky.profile so direnv can source it
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

        # ar: AWS Region switcher
        # Usage: ar [query] -- fuzzy-select an AWS region and export it
        # Persists selection to ~/.aws/sticky.region
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

        # ── herdr: run a command in a fresh tab ──────────────────────
        # herdr has no `tab spawn`/`--command`; the flow is: create a tab,
        # read its root pane id from the JSON, then `pane run` in it. These
         # wrap that so you can do `hrf vim` / `hrn vim` (all args are joined
         # into one command line run in the new tab's zsh). Named hrn (not hr)
         # to avoid colliding with the `hr` = `herdr --remote` alias (herdr.nix).

        # _herdr_new_tab: create a tab and run "$@" in it.
        # $1 = "focus" | "no-focus"; remaining args = command to run.
        _herdr_new_tab() {
          local focus_flag="$1"; shift
          if [[ -z "$*" ]]; then
            echo "usage: ''${funcstack[2]} COMMAND [ARGS...]" >&2
            return 1
          fi
          local pane_id
          pane_id="$(herdr tab create --"$focus_flag" \
            | ${pkgs.jq}/bin/jq -r '.result.root_pane.pane_id')" || return
          if [[ -z "$pane_id" || "$pane_id" == "null" ]]; then
            echo "herdr: could not determine new pane id" >&2
            return 1
          fi
          herdr pane run "$pane_id" "$*"
        }

        # hrf: launch a command in a new tab and focus it.
        hrf() { _herdr_new_tab focus "$@"; }

        # hrn: launch a command in a new tab without focusing it.
        hrn() { _herdr_new_tab no-focus "$@"; }

        # ── lazyworktree: TUI git worktree manager ───────────────────
        # Source built-in shell functions (worktree_jump, worktree_go_last)
        source ${pkgs.lazyworktree}/share/lazyworktree/functions.zsh

        # wt: jump to a worktree in the current repo via lazyworktree TUI
        wt() {
          local toplevel
          toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || {
            echo "wt: not inside a git repo" >&2
            return 1
          }
          worktree_jump "$toplevel" "$@"
        }

        # rst: reset shell environment -- clear AWS/kube context, return to ~/source.
        # Defined as a function (not a shellAlias) because zsh aliases can't span
        # multiple commands cleanly, and it must mutate the current shell.
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
        # Usage: curl-all-ips HOST [PATH] [PORT]   (PATH defaults to /, PORT to 443)
        # Each request is pinned to one resolved IP via curl --resolve, so the
        # Host header, SNI, and TLS cert validation all still target HOST while
        # the connection actually hits that specific backend IP. Prints one line
        # per IP: the IP plus HTTP status and total time (body discarded). Useful
        # for spotting a single unhealthy/slow node behind a round-robin record.
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
