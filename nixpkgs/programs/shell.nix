{ config, pkgs, ... }:
{
  programs = {

    direnv.enable = true;

    powerline-go = {
      enable = true;
      modules = [ "ssh" "host" "cwd" "venv" "git" "perms" "nix-shell" "kube" ];
      newline = true;
      settings = {
        colorize-hostname = true;
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;

      initExtra = ''
        # Single tab complete
        #unsetopt listambiguous
        setopt menu_complete
      '';

      sessionVariables = {
        EDITOR="nvim";
        RPS1="";
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
