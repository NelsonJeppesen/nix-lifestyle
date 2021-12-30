{ config, pkgs, ... }:
{

  programs = {
    git = {
      enable = true;
      userName = "Nelson Jeppesen";
      userEmail = "50854675+NelsonJeppesen@users.noreply.github.com";

      ignores = [
        # ignore direv files
        ".envrc"
      ];

      extraConfig = {
        pull = {
          ff       = "only";
        };

        push = {
          default  = "current";
        };
      };

      aliases = {
        a     = "add";
        ap    = "add * --patch";
        b     = "branch";
        co    = "checkout";
        ct    = "commit -m";
        some  = "!git fetch -a && git pull";
        ps    = "push";
        psf   = "push --force-with-lease";
        s     = "status";

        st    = "stash";
        stp   = "stash pop";
        stc   = "stash clear";

        dmast = "diff origin/master";
        dmain = "diff origin/main";
        dcicd = "diff origin/cicd";

        rbhead = "rebase -i HEAD~9";
        rbmast = "rebase -i origin/master";
        rbmain = "rebase -i origin/main";
        rbcicd = "rebase -i origin/cicd";

        rba   = "rebase --abort";
        rbc   = "rebase --continue";
      };
    };
  };
}
