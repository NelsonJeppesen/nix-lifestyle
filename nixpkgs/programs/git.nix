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
        pager = {
          diff    = "false";
          log     = "false";
          reflog  = "false";
          show    = "false";
          branch  = "false";
        };

        #delta = {

        #  plus-style    = "syntax #012800";
        #  minus-style   = "syntax #340001";
        #  syntax-theme  = "Nord";
        #  navigate      = true;
        #};

        #interactive = {
        #  diffFilter = "delta --color-only";
        #};

        pull = {
          ff       = "only";
        };

        push = {
          default  = "current";
        };

        #color = {
        #  diff        = "auto";
        #  status      = "auto";
        #  branch      = "auto";
        #  interactive = "auto";
        #  ui          = true;
        #  pager       = false;
        #};
      };

      aliases = {
        a     = "add";
        ap    = "add * --patch";
        b     = "branch";
        co    = "checkout";
        ct    = "commit";
        some  = "!git fetch -a && git pull";
        ps    = "push";
        psf   = "push --force-with-lease";
        s     = "status";

        st    = "stash";
        stp   = "stash pop";
        stc   = "stash clear";

        dmast   = "diff origin/mast";
        dmain   = "diff origin/main";
        dcicd   = "diff origin/cicd";

        rb    = "rebase -i HEAD~9";
        rba   = "rebase --abort";
        rbc   = "rebase --continue";
      };
    };
  };
}
