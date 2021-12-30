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
        pull = { ff       = "only";     };
        push = { default  = "current";  };
      };

      aliases = {
        a      = "add";
        ap     = "add * --patch";
        co     = "checkout";
        ct     = "commit -m";
        some   = "!git fetch -a && git pull";
        ps     = "push";
        psf    = "push --force-with-lease";
        s      = "status";

        st     = "stash";
        stp    = "stash pop";
        stc    = "stash clear";

        dfmast = "diff origin/master";
        dfm    = "diff origin/main";

        rbhead = "rebase --interactive HEAD~9";
        rbmast = "rebase --interactive origin/master";
        rb     = "rebase --interactive origin/main";
        rba    = "rebase --abort";
        rbc    = "rebase --continue";
      };
    };
  };
}
