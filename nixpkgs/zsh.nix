{ config, pkgs, ... }:
{
  programs = {

    direnv.enable = true;
    fzf.enable    = true;

    # Clean prompt with the features I need
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        # Disabled
        aws.disabled        = true;
        helm.disabled       = true;
        terraform.disabled  = true;

        # Enabled
        kubernetes.disabled = false;
      };
    };

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
        # Enable aliases from within `watch`
        watch   = "watch ";

        # Google from the terminal
        g       = "googler";
        gf      = "googler --first";
        gg      = "googler --noprompt";
        gw      = "googler --site en.wikipedia.org";
        gwf     = "googler --site en.wikipedia.org --first";

        # Kube
        rst     = "cd ~/s; clear";
        uc      = "kubectx";
        k       = "kubectl";
        kns     = "kubens";
        kg      = "kubectl get";
        kgs     = ''kubectl get --no-headers -o custom-columns=":metadata.name"'';

        # Notes
        n       = "vim ~/s/notes/$(date +work-%Y-%q).md";
        s       = "vim ~/s/notes/scratch.md";
      };
    };
  };
}
