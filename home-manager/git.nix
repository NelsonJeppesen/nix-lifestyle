{ config, pkgs, ... }:
{
  home.file.".ssh/allowed_signers".text = "* ${builtins.readFile /home/nelson/.ssh/id_ed25519.pub}";

  programs = {

    git = {
      enable = true;
      userName = "Nelson Jeppesen";
      userEmail = "50854675+NelsonJeppesen@users.noreply.github.com";

      ignores = [
        # ignore direv files
        ".envrc"
      ];
      difftastic = {
        enable = true;
      };

      extraConfig = {
        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";

        # Sign all commits using ssh key
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        merge.conflictstyle = "zdiff3";
        user.signingkey = "~/.ssh/id_ed25519.pub";

        pull = {
          ff = "only";
        };
        push = {
          default = "current";
        };
      };

      aliases = {
        a = "add";
        ap = "add * --patch";
        br = "!git co $(git branch --list --sort=-authordate |fzf --height 15)";
        c = "commit -m";
        co = "checkout";

        de = "!git diff --name-only | uniq | xargs vim";

        d1 = "diff HEAD~1";
        d2 = "diff HEAD~2";
        d3 = "diff HEAD~3";
        d4 = "diff HEAD~4";

        da = "!git diff --name-only | uniq | xargs git add";
        dap = "!git diff --name-only | uniq | xargs git add --patch";

        cp = "cherry-pick";
        cpa = "cherry-pick --abort";
        cpc = "cherry-pick --continue";

        d = "diff";
        dfm = "diff origin/main";
        dfmast = "diff origin/master";
        ps = "push";
        psf = "push --force-with-lease";

        rb = "rebase --interactive origin/main";
        rbm = "rebase --interactive origin/master";
        rba = "rebase --abort";
        rbc = "rebase --continue";
        rbh = "rebase --interactive HEAD~9";

        rl = "reflog";
        s = "status";
        some = "!git fetch -a && git pull";

        st = "stash";
        stc = "stash clear";
        stp = "stash pop";

        w = "worktree";
        wa = "worktree add";
        wl = "worktree list";
        wp = "worktree prune";
        wr = "worktree remove";
      };
    };
  };
}
