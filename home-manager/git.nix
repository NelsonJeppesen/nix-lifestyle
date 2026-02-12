# git.nix - Git version control configuration
#
# Configures git with:
# - User identity using GitHub noreply email for privacy
# - SSH commit signing (ed25519 key)
# - Difftastic for structural/syntax-aware diffs
# - GitAlias community aliases (imported from gitalias flake input)
# - SSH-forced URLs for GitHub and Bitbucket (no HTTPS prompts)
# - Fast-forward-only pulls to prevent accidental merge commits
# - Auto-setup remote on push for new branches
# - lazyworktree TUI for multi-branch workflows
{ config, gitalias, ... }:
{
  # Generate the SSH allowed_signers file from the user's ed25519 public key.
  # This file is required for git to verify SSH-signed commits.
  # Runs after writeBoundary so home.file entries are already in place.
  home.activation.createAllowedSigners = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f "${config.home.homeDirectory}/.ssh/id_ed25519.pub" ]; then
      $DRY_RUN_CMD rm -f ${config.home.homeDirectory}/.ssh/allowed_signers
      $DRY_RUN_CMD echo "* $(cat ${config.home.homeDirectory}/.ssh/id_ed25519.pub)" > ${config.home.homeDirectory}/.ssh/allowed_signers
    fi
  '';

  programs = {

    lazyworktree = {
      enable = true;
      settings = {
        worktree_dir = "~/source/.worktrees";
      };
    };

    # difftastic: structural diff tool that understands syntax
    # Provides much better diffs for code than line-based diff
    difftastic = {
      enable = true;
      git.enable = true; # Register as git's default diff tool
    };

    git = {
      enable = true;

      # Include community-curated git aliases from the GitAlias project
      # https://github.com/GitAlias/gitalias
      includes = [
        { path = "${gitalias}/gitalias.txt"; }
      ];

      # Global gitignore patterns
      ignores = [
        ".envrc" # direnv files often contain secrets
      ];

      settings = {
        # User identity (GitHub noreply email for privacy)
        user = {
          name = "Nelson Jeppesen";
          email = "50854675+NelsonJeppesen@users.noreply.github.com";
          signingkey = "~/.ssh/id_ed25519.pub";
        };

        # Custom aliases (supplements the GitAlias includes above)
        alias = {
          pu = "push";
          puf = "!git push --force-with-lease --force-if-includes"; # Safe force push
          br = "!git co $(git branch --list --sort=-committerdate|fzf --height 15)"; # Interactive branch switch via fzf
          wt = "!lazyworktree"; # TUI worktree manager
          # open: Open the current GitHub repo in a browser
          # Usage: git open [path]
          # Supports both SSH and HTTPS remote URLs; errors on non-GitHub remotes
          open = ''
            !f() { \
              url="$(git remote get-url origin 2>/dev/null)" || { echo "no remote 'origin'" >&2; return 1; }; \
              case "$url" in \
                git@github.com:*) repo="''${url#git@github.com:}" ;; \
                https://github.com/*) repo="''${url#https://github.com/}" ;; \
                *) echo "not a github repo" >&2; return 1 ;; \
              esac; \
              repo="''${repo%.git}"; \
              branch="$(git rev-parse --abbrev-ref HEAD)"; \
              path="''${1:+/tree/$branch/$1}"; \
              : "''${path:=/tree/$branch}"; \
              xdg-open "https://github.com/$repo$path"; \
            }; f
          ''; # Open GitHub repo in browser at current branch and optional path
        };

        # Sign all commits with SSH key
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";

        # Use zdiff3 conflict markers (shows base version in addition to ours/theirs)
        merge.conflictstyle = "zdiff3";

        # Force SSH for GitHub and Bitbucket (avoids HTTPS credential prompts)
        url."git@github.com:".insteadOf = "https://github.com/";
        url."git@bitbucket.org:".insteadOf = "https://bitbucket.org/";

        # Sort branches by most recent commit (most useful at top)
        branch = {
          sort = "-committerdate";
        };

        # Fast-forward only pulls to prevent accidental merge commits
        pull = {
          ff = "only";
        };

        # Push to current branch by default and auto-create upstream tracking
        push = {
          default = "current";
          autoSetupRemote = "true";
        };

        # Store credentials on disk (used for non-SSH remotes)
        credential = {
          helper = "store";
        };
      };
    };
  };
}
