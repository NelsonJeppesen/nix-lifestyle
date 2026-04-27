# Commit and Push

Stage all relevant changes, create a commit, and push to the
current branch's upstream.

Steps:
1. Run `git status` and `git diff` (staged + unstaged) in parallel
   to understand what changed. Also run `git log -n 5 --oneline`
   to match this repo's commit message style.
2. Decide which untracked/modified files belong in the commit.
   Skip anything that looks like a secret (`.env`, `*.age`,
   `credentials*`, `id_*`, etc.) — warn the user instead.
3. Draft a concise commit message:
   - Imperative mood, ≤72 char subject
   - Focus on the "why", not the "what"
   - Match the repo's existing tone (check recent log)
4. `git add` the chosen files, then `git commit -m "<message>"`.
   Commits MUST be signed if the repo requires it (this repo does
   — SSH-signed); do not pass `--no-verify` or `--no-gpg-sign`.
5. If the pre-commit hook modifies files, stage those changes and
   create a NEW commit (do NOT `--amend` unless the user asks).
6. Push to the upstream branch. If the branch has no upstream,
   push with `-u origin <branch>`. Never force-push without
   explicit user request; never force-push to main/master.
7. Run `git status` afterwards to confirm a clean tree and that
   the branch is in sync with the remote.

If there is nothing to commit, say so and stop — do not create
an empty commit.
