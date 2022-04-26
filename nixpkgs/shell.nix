{ config, pkgs, ... }:
{
  programs = {

    direnv.enable  = true;
    fzf.enable     = true;
    nushell.enable = true;
    zoxide.enable  = true;

    zsh = {
      enable = true;

      history = {
        # Keep everything
        extended = true;
        save = 999999;
        size = 999999;
      };

      enableAutosuggestions     = true;
      enableCompletion          = true;
      enableSyntaxHighlighting  = true;

      initExtraFirst = ''
        # Setup emacs keybindings before fzf bindings are added
        bindkey -e
      '';

      initExtra = ''
        # Set Kitty Terminal title of PWD
        function set-title-precmd() {
          printf "\e]2;%s\a" "''${PWD/#$HOME/~}"
        }

        # Set Kitty Terminal title to the running command
        function set-title-preexec() {
          printf "\e]2;%s\a" "$1"
        }

        # Use menu for autocomplete
        # https://stackoverflow.com/questions/13613698/zsh-history-completion-menu
        zstyle ':completion:*' menu yes select

        # https://superuser.com/questions/160750/can-zsh-do-2-stage-completion
        zstyle ':completion:*' menu select=1
        zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

        #autoload -Uz add-zsh-hook
        add-zsh-hook precmd set-title-precmd
        add-zsh-hook preexec set-title-preexec

        # If opening a new terminal, switch to ~s and clear the screen
        if [ "$TERM" != "linux" ]; then
          if [ "$(pwd)" = "$HOME" ]; then
            cd ~/s
            clear
          fi
        fi
      '';

      sessionVariables = {
        # Install non-free packages e.g. Steam
        NIXPKGS_ALLOW_UNFREE = "1";

        # Autosuggest as orange
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";

        # Use NeoVim is my editor for all
        EDITOR = "nvim";

        # Use NemVim as my pager; enable copy into clipboard
        PAGER = "nvimpager -- --cmd 'set clipboard^=unnamed,unnamedplus'";
      };

      shellAliases = {
        # fuzzy open this nix config in neovim
        mynix = ''vim $(find ~/s/play/nix-lifestyle|grep  '.nix$'|fzf)'';

        # short 'n sweet
        g = "~/.nix-profile/bin/git";
        h = "~/.nix-profile/bin/helmfile";
        n = "vim ~/s/notes/$(date +work-%Y-%q).md";
        s = "vim ~/s/notes/scratch.md";

        # retrain my old mind
        git = "bad";
        helmfile = "bad";

        # use zoxide
        cd     = "z";
        ".."   = "z ..";
        "..."  = "z ../..";
        "...." = "z ../../..";

        # Enable aliases from within `watch`
        watch = "watch ";

        # reset terminal
        rst = "cd ~/s; clear";

        # fend calculator
        f  = "fend";
        ff = "clear;fend";

        # terraform
        t   = "terraform";
        ta  = "terraform apply";
        ti  = "terraform init";
        tp  = "terraform plan";
        tsd = "terraform state rm   $(terraform state list | fzf --multi)";
        tss = "terraform state show $(terraform state list | fzf)";
        tt  = "terraform taint      $(terraform state list | fzf --multi)";

        # use fuzzy finder to connect to one more more vpns quickly
        vpn = "nmcli con|grep vpn|grep -- --|choose 0|fzf --multi|xargs --max-procs 9 -L1 nmcli con up id";

        # kube
        uc  = "kubectx";
        k   = "kubectl";
        kns = "kubens";
        kg  = "kubectl get";
        kgs = ''kubectl get --no-headers -o custom-columns=":metadata.name"'';
        kdp = "k delete pod $(kgs pod|fzf --multi)";

        # interactive ripgrep
        irg = ''INITIAL_QUERY=""
          RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case " \
          FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'"     \
          fzf -m --bind "change:reload:$RG_PREFIX {q} || true"  \
              --ansi --disabled --query "$INITIAL_QUERY"        \
              --height=50% --layout=reverse'';
      };
    };
  };
}
