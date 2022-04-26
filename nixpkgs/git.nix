{ config, pkgs, ... }:
{
  home.file.".ssh/allowed_signers".text =
    "* ${builtins.readFile /home/nelson/.ssh/id_ed25519.pub}";

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
        br     = ''!git branch --all --sort=authordate --format="%(color:blue)%(authordate:relative);%(color:red)%(authorname);%(color:white)%(color:bold)%(refname:short)" "$@" | column -s ";" -t'';
        c      = "commit -m";
        co     = "checkout";
        dfm    = "diff origin/main";
        dfmast = "diff origin/master";
        ps     = "push";
        psf    = "push --force-with-lease";
        rb     = "rebase --interactive origin/main";
        rba    = "rebase --abort";
        rbc    = "rebase --continue";
        rbhead = "rebase --interactive HEAD~9";
        rbmast = "rebase --interactive origin/master";
        s      = "status";
        some   = "!git fetch -a && git pull";
        st     = "stash";
        stc    = "stash clear";
        stp    = "stash pop";
      };
    };
  };
}
