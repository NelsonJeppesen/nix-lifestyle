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
        #pager = {
        #  diff    = "delta";
        #  log     = "delta";
        #  reflog  = "delta";
        #  show    = "delta";
        #};

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

        color = {
          diff        = "auto";
          status      = "auto";
          branch      = "auto";
          interactive = "auto";
          ui          = true;
          pager       = true;
        };
      };

      aliases = {
        a     = "add";
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
        dfm   = "diff origin/master";
        l     = "log -p --color";
        l1    = "log -1 HEAD";
        rb    = "rebase -i HEAD~9";
        rba   = "rebase --abort";
        rbc   = "rebase --continue";
      };
    };
  };
}
