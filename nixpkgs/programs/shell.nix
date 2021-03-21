{ config, pkgs, ... }:
{
  programs = {

    zsh = {
      enable = true;

      enableCompletion = true;
      enableAutosuggestions = true;

      initExtra = ''
        # Single tab complete
        #unsetopt listambiguous
        setopt menu_complete

        function powerline_precmd() {
          eval "$(${pkgs.powerline-go}/bin/powerline-go -error $? -shell zsh -eval -modules ssh,host,cwd,venv,git,perms,nix-shell -modules-right kube -newline)"
        }

        function install_powerline_precmd() {
          for s in "$\{precmd_functions[@]}"; do
            if [ "$s" = "powerline_precmd" ]; then
              return
            fi
          done
          precmd_functions+=(powerline_precmd)
        }

        eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

        if [ "$TERM" != "linux" ]; then
          install_powerline_precmd
          cd ~/src
          clear
        fi
      '';

      sessionVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=4";
        EDITOR = "nvim";
        RPS1 = "";
      };

      shellAliases = {
        update-all    = "sudo nixos-rebuild switch --upgrade;nix-channel --update; home-manager switch";
        update-os     = "sudo nixos-rebuild switch --upgrade;nix-channel --update";
        update-hm     = "nix-channel --update; home-manager switch";
        rst           = "kubectx -u; cd ~/src; clear";

        uc            = "kubectx";
        k             = "kubectl";
        kd            = "kubectl describe";
        kg            = "kubectl get";
        kl            = "kubectl logs";
        kgp           = "kubectl get pod";
        ke            = "kubectl edit";
        kns           = "kubens";

        playDronezone       = "clear;echo -e '\\033[36mPlaying dronezone';somafm play dronezone";
        playMissioncontrol  = "clear;echo -e '\\033[36mPlaying missioncontrol';somafm play missioncontrol";
        playSf1033          = "clear;echo -e '\\033[36mPlaying sf1033';somafm play sf1033";

      };
    };
  };
}
