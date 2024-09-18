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

        credential = {
          helper = "store";
        };
      };
    };
  };
}
