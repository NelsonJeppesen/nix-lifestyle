{ ... }:
let
  gitalias = builtins.fetchGit {
    url = "https://github.com/GitAlias/gitalias.git";
    ref = "main";
  };

in
{
  home.file.".ssh/allowed_signers".text = "* ${builtins.readFile /home/nelson/.ssh/id_ed25519.pub}";

  programs = {

    git-worktree-switcher = {
      enable = true;
    };

    difftastic = {
      enable = true;
      git.enable = true;
    };

    git = {
      enable = true;

      includes = [
        { path = "${gitalias}/gitalias.txt"; }
      ];

      ignores = [
        ".envrc"
      ];

      settings = {
        user = {
          name = "Nelson Jeppesen";
          email = "50854675+NelsonJeppesen@users.noreply.github.com";
          signingkey = "~/.ssh/id_ed25519.pub";
        };

        alias = {
          pu = "push";
          puf = "!git push --force-with-lease --force-if-includes";
          br = "!git co $(git branch --list --sort=-committerdate|fzf --height 15)";
        };

        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        merge.conflictstyle = "zdiff3";

        url."git@github.com:".insteadOf = "https://github.com/";
        url."git@bitbucket.org:".insteadOf = "https://bitbucket.org/";

        branch = {
          sort = "-committerdate";
        };

        pull = {
          ff = "only";
        };
        push = {
          default = "current";
          autoSetupRemote = "true";
        };

        credential = {
          helper = "store";
        };
      };
    };
  };
}
