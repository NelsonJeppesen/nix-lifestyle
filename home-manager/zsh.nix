# zsh.nix - Zsh shell configuration
#
# Configures the Z shell with:
# - direnv integration for per-directory environment variables
# - fzf for fuzzy finding (files, history, completions)
# - Atuin for shell history sync (syncs to local server at 192.168.5.0)
# - Starship cross-shell prompt with Kubernetes context and AWS profile display
# - fzf-tab plugin for tab completion with fuzzy matching
# - Custom functions: ap (AWS profile), ar (AWS region), nsr (nix-shell-run), rgreplace, wt (worktree jump)
# - Extensive shell aliases for terraform, kubectl, git, clipboard, and notes
# - Kitty terminal tab title integration (shows PWD and running command)
{ config, pkgs, ... }:
{
  programs = {
    # direnv: automatically load/unload .envrc environment variables per directory
    direnv.enable = true;

    # fzf: fuzzy finder used throughout the shell (history, file picker, etc.)
    fzf = {
      enable = true;
      defaultOptions = [
        "--layout=reverse" # Show results top-to-bottom (feels more natural)
        # "--color=bw"
      ];
    };

    # Atuin: replacement shell history that syncs across machines
    # Stores history in SQLite and syncs to a self-hosted server on the LAN
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ]; # Don't hijack up-arrow (use Ctrl+R instead)

      settings = {
        filter_mode = "workspace"; # Filter history by current git repo/directory
        keymap_mode = "emacs"; # Use emacs-style keybindings in search UI
        search_node = "fulltext"; # Full-text search across command history
        secrets_filter = true; # Automatically filter out commands containing secrets
        show_preview = true; # Show command preview in search results
        sync_address = "http://192.168.5.0:8888"; # Self-hosted Atuin sync server on LAN
      };
    };

    # Starship: minimal, fast, cross-shell prompt
    # Displays git status, AWS profile/region, Kubernetes context, and directory
    starship = {
      enable = true;
      settings = {
        # Disable noisy/unhelpful prompt modules
        cmd_duration.disabled = true;
        helm.disabled = true;
        python.disabled = true;
        terraform.disabled = true;

        #right_format = "$kubernetes$line_break";

        # Fill character between left and right prompt sections
        fill = {
          symbol = " ";
        };

        # Custom prompt layout: main info on first line, directory/git on second
        # Kubernetes context is pushed to the right side of the first line
        format = "$all$fill$kubernetes$line_break$directory$git_branch$git_status\${custom.worktree}$jobs$battery$time$status$os$container$shell$character";

        # Directory display: show up to 9 levels, highlight repo root
        directory = {
          truncation_length = 9;
          repo_root_style = "bright-yellow";
        };

        # Git status indicators (modified, staged, ahead/behind)
        git_status = {
          format = "([$all_status$ahead_behind]($style))\\] ";
          #up_to_date = "[✓](green)";
          #stashed = "[\\$\\($count\\)](green)";
          #deleted = "[--\\($count\\)](red)";
        };

        # Git branch display format
        git_branch = {
          format = "\\[[$branch(:$remote_branch)]($style) ";
        };

        # AWS profile and region display with short region aliases
        aws = {
          # $duration
          format = "\\[[$profile]($style) $region\\]";
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

        # Show worktree name when inside a git worktree
        custom.worktree = {
          when = "test -f .git"; # .git is a file (not dir) inside worktrees
          command = "basename $(pwd)";
          format = "[wt:$output]($style) ";
          style = "bold cyan";
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
        # {
        #   file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        #   name = "zsh-vi-mode";
        #   src = pkgs.zsh-vi-mode;
        # }
      ];

      autosuggestion.enable = true; # Fish-like autosuggestions based on history
      defaultKeymap = "emacs"; # Emacs-style line editing (Ctrl+A/E, etc.)
      enableCompletion = true; # Enable zsh completion system
      syntaxHighlighting.enable = true; # Real-time syntax highlighting as you type

      # Shell initialization code (runs on every new shell)
      initContent = ''
        # ── Kitty tab title integration ─────────────────────────────
        # Show current directory name as tab title when idle
        function set-title-precmd() {printf "\e]2;%s\a" "''${PWD/*\//}"}
        add-zsh-hook precmd set-title-precmd

        # Show running command name as tab title while executing
        function set-title-preexec() {printf "\e]2;%s\a" "$1"}
        add-zsh-hook preexec set-title-preexec

        # ── Auto-cd to source directory on new terminal ─────────────
        # If opening a new terminal (not over SSH), cd to ~/source and clear
        if [[ "$TERM" != "linux" && "$(pwd)" = "$HOME" && ! "$SSH_CLIENT" ]]; then
          cd ~/source
          clear
        fi

        # ── Custom shell functions ──────────────────────────────────

        # ap: AWS Profile switcher
        # Usage: ap [query] -- fuzzy-select an AWS profile and export it
        # Persists selection to ~/.aws/sticky.profile so direnv can source it
        ap() {
          local query="$1"
          local profile
          profile="$(${pkgs.awscli2}/bin/aws configure list-profiles | sort | ${pkgs.fzf}/bin/fzf --exact --query="$query" --select-1)"
          if [ -n "$profile" ]; then
            echo export AWS_PROFILE="$profile" > ~/.aws/sticky.profile
            source ~/.aws/sticky.profile
          fi
        }

        # ar: AWS Region switcher
        # Usage: ar [query] -- fuzzy-select an AWS region and export it
        # Persists selection to ~/.aws/sticky.region
        ar() {
          local query="$1"
          local region
          region="$(printf '%s\n' us-east-1 ca-central-1 eu-central-1 ap-southeast-2 | ${pkgs.fzf}/bin/fzf --exact --query="$query" --select-1)"
          if [ -n "$region" ]; then
            echo export AWS_REGION="$region" > ~/.aws/sticky.region
            source ~/.aws/sticky.region
          fi
        }

        # nsr: Nix Shell Run -- quickly run a command from a nix package
        # Usage: nsr <package> [command]
        # If command is omitted, uses the package name as the command
        nsr() {
          if [ -z "$1" ]; then
            echo "usage: nsr <package> [command]" >&2
            return 1
          fi
          local pkg="$1"
          local run_cmd="''${2:-$1}"
          set -x
          nix-shell --packages "$pkg" --run "$run_cmd"
        }

        # ── lazyworktree: TUI git worktree manager ───────────────────
        # Source built-in shell functions (worktree_jump, worktree_go_last)
        source ${pkgs.lazyworktree}/share/lazyworktree/functions.shell

        # wt: jump to a worktree in the current repo via lazyworktree TUI
        wt() {
          local toplevel
          toplevel="$(git rev-parse --show-toplevel 2>/dev/null)" || {
            echo "wt: not inside a git repo" >&2
            return 1
          }
          worktree_jump "$toplevel" "$@"
        }

        # rgreplace: bulk search and replace across files using ripgrep + sed
        # Usage: rgreplace <search> <replace> [path]
        rgreplace() {
          if [ $# -lt 2 ]; then
            echo "usage: rgreplace <search> <replace> [path]" >&2
            return 1
          fi
          local search="$1"
          local replace="$2"
          local path="''${3:-.}"
          ${pkgs.ripgrep}/bin/rg -l -- "$search" "$path" | ${pkgs.findutils}/bin/xargs -r -n1 ${pkgs.gnused}/bin/sed -i "s|$search|$replace|g"
        }
        # ------------------------------------------------------------
      '';

      # Environment variables set for every zsh session
      sessionVariables = {
        DIRENV_LOG_FORMAT = ""; # Silence direnv "loading .envrc" messages
        MANPAGER = "vim +Man!"; # Use vim as the man page viewer
        NIXPKGS_ALLOW_UNFREE = "1"; # Allow unfree packages in nix-shell

        # Enable system clipboard integration for zsh-vi-mode (if re-enabled)
        ZVM_SYSTEM_CLIPBOARD_ENABLED = true;
      };

      # ── Shell aliases ─────────────────────────────────────────────
      shellAliases = {
        # System
        reboot-bios = "systemctl reboot --firmware-setup"; # Reboot directly into UEFI/BIOS

        # AWS
        al = "aws sso login"; # Quick SSO login

        # Clipboard (Wayland-only via wl-clipboard)
        cbc = "${pkgs.wl-clipboard}/bin/wl-copy"; # Pipe to clipboard
        cbp = "${pkgs.wl-clipboard}/bin/wl-"; # Paste from clipboard

        # Git
        g = "${pkgs.git}/bin/git";

        # direnv
        da = "direnv allow"; # Quick allow for .envrc changes

        # Notes (nb-based note-taking)
        # n = "vim $(ls ~/personal/notes/*.md | fzf --multi)";
        nw = "nb edit work-$(date +%Y-%m).md      2>/dev/null || nb add --title work-$(date +%Y-%m)"; # Work notes (monthly)
        np = "nb edit personal-$(date +%Y-%m).md  2>/dev/null || nb add --title personal-$(date +%Y-%m)"; # Personal notes (monthly)
        ns = "$EDITOR $(mktemp)"; # Scratch note in temp file

        # Reset environment: clear AWS/kube context and go back to ~/source
        rst = ''
          cd ~/source
          kubectx --unset
          echo > ~/.aws/sticky.profile
          echo > ~/.aws/sticky.region
          unset AWS_PROFILE
          unset AWS_REGION
          clear
        '';

        # Calculator (fend)
        f = "fend";
        fc = "clear;fend";

        # Terraform aliases (short commands for daily IaC work)
        t = "${pkgs.terraform}/bin/terraform";
        ta = "${pkgs.terraform}/bin/terraform apply";
        ti = "${pkgs.terraform}/bin/terraform init";
        tp = "${pkgs.terraform}/bin/terraform plan";
        tpv = "${pkgs.terraform}/bin/terraform plan -no-color | vim"; # Plan output in vim for review
        tpwb = "${pkgs.terraform}/bin/terraform plan -no-color | grep 'will be'"; # Quick summary of what will change
        tsd = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform state rm"; # Fuzzy state remove
        tss = "${pkgs.terraform}/bin/terraform state show $(${pkgs.terraform}/bin/terraform state list|fzf)"; # Fuzzy state show
        tt = "echo $(${pkgs.terraform}/bin/terraform state list|fzf --multi)|xargs -n1 ${pkgs.terraform}/bin/terraform taint"; # Fuzzy taint

        # Kubernetes aliases
        k = "kubectl";
        kns = "kubens"; # Quick namespace switch
        uc = "kubectx"; # Quick context switch
        ucu = "kubectx --unset"; # Unset current context
      };
    };
  };
}
