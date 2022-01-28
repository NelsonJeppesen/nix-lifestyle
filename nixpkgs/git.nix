{ config, pkgs, ... }:
{
  home.file.".ssh/allowed_signers".text = "* ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCxOtyuxSM3W1bY38x9GxuCFSe9VsN6NpamKxboJAW";

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
        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        user.signingkey = "~/.ssh/id_ed25519.pub";

        pull = { ff       = "only";     };
        push = { default  = "current";  };
      };

      aliases = {
        a      = "add";
        ap     = "add * --patch";
        co     = "checkout";
        c      = "commit -m";
        some   = "!git fetch -a && git pull";

        # Create reate a list of branches sorted by last updated with authorname
        br     = ''!git branch --all --sort=authordate --format="%(color:blue)%(authordate:relative);%(color:red)%(authorname);%(color:white)%(color:bold)%(refname:short)" "$@" | column -s ";" -t'';

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
