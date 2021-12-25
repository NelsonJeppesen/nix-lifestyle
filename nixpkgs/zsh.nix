{ config, pkgs, ... }:
{
  programs = {

    direnv.enable = true;

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

      enableCompletion = true;
      enableAutosuggestions = true;

      initExtra = ''
        bindkey -e
        #unsetopt menucomplete

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
        # Update nixos
        update        = "sudo nixos-rebuild switch --upgrade && echo ------------ && nix-channel --update && echo ------------ && home-manager switch";

        # allow watch to run aliases
        watch         = "watch ";

        # Kube
        rst           = "kubectx -u; cd ~/s; clear";
        uc            = "kubectx";
        ucu           = "kubectx -u";
        k             = "kubectl";
        kd            = "kubectl describe";
        kg            = "kubectl get";
        kl            = "kubectl logs";
        kgp           = "kubectl get pod";
        ke            = "kubectl edit";
        kns           = "kubens";

        # Notes
        n             = "vim ~/s/notes/$(date +work-%Y-%W).md";
        nw            = "vim ~/s/notes/$(date +work-%Y-%W -d 'next week').md";  # note for next week
        s             = "vim ~/s/notes/scratch.md";
      };
    };
  };
}