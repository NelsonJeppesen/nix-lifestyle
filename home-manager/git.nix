# git.nix - Git version control configuration
{
  config,
  lib,
  pkgs,
  gitalias,
  ...
}:
{
  home.packages = [ pkgs.hunk ]; # Review-first diff viewer with live AI annotations

  # Hunk ships the skill matching its session API, so it stays in sync with
  # the nixpkgs package version used by the Git pager.
  home.file.".config/opencode/skills/hunk-review/SKILL.md".source =
    "${pkgs.hunk}/skills/hunk-review/SKILL.md";

  # Generate the SSH allowed_signers file from the user's ed25519 public key.
  # This file is required for git to verify SSH-signed commits.
  # Runs after writeBoundary so home.file entries are already in place.
  # Quoted paths handle home directories containing spaces/metacharacters.
  home.activation.createAllowedSigners = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    pubkey="${config.home.homeDirectory}/.ssh/id_ed25519.pub"
    out="${config.home.homeDirectory}/.ssh/allowed_signers"
    if [ -r "$pubkey" ]; then
      $DRY_RUN_CMD install -m 600 /dev/null "$out"
      $DRY_RUN_CMD sh -c "printf '* %s\n' \"\$(cat \"$pubkey\")\" > \"$out\""
    else
      $VERBOSE_ECHO "git.nix: $pubkey missing; skipping allowed_signers generation"
    fi
  '';

  programs = {
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
        ".notes/" # nvim scratch buffers (see neovim.nix VimEnter autocmd)
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
          br = ''
            !f() { \
              branch=$(git branch --format='%(refname:short)' --sort=-committerdate | fzf --height 15) || return; \
              git switch "$branch"; \
            }; f
          '';
          # git alias app: interactive add -p that includes untracked files
          # Uses fzf to select which untracked files to intent-to-add before patching
          app = ''
            !f() { \
              git ls-files --others --exclude-standard -z \
                | fzf --read0 --print0 --multi --preview 'cat -- {}' --header 'Select untracked files to include in patch review' \
                | xargs -0 -r git add -N; \
              git add -p; \
            }; f
          '';
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

        merge.conflictStyle = "zdiff3"; # Include the base version in conflict markers

        core.pager = "${lib.getExe pkgs.hunk} pager";

        # Force SSH for GitHub, GitLab, and Bitbucket (avoids HTTPS credential prompts)
        url."git@github.com:".insteadOf = "https://github.com/";
        url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
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
          autoSetupRemote = true;
        };

      };
    };

    opencode.commands = {
      diff-review = ''
        Review the current working tree for bugs, regressions, security issues,
        and missing tests. Load the hunk-review skill and use the live Hunk
        session for this repository when one exists. Put actionable findings
        inline in Hunk and summarize them in severity order. Do not edit files.
      '';
      pr-review = ''
        Review GitHub pull request $ARGUMENTS. Use the GitHub tools to inspect
        its metadata, complete diff, commits, checks, and existing review
        threads. Focus on bugs, regressions, security issues, and missing tests;
        report findings first with file and line references. Do not edit files,
        submit a GitHub review, or post comments unless explicitly asked.
      '';
    };
  };
}
