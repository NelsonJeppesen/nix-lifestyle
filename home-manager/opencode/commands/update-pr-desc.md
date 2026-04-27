# Update Pull Request Description

Regenerate the description (body) of the pull request associated
with the current branch so it accurately reflects ALL commits in
the PR — not just the latest one.

Steps:
1. Determine the current branch and its PR:
   - `git branch --show-current`
   - `gh pr view --json number,title,body,baseRefName,headRefName,url`
   If there is no open PR for this branch, stop and tell the user.
2. Gather the full PR context (run in parallel where possible):
   - `git log <base>..HEAD --reverse --pretty=format:'%h %s%n%b'`
     to get every commit's subject + body
   - `git diff <base>...HEAD --stat` for a high-level change map
   - `gh pr view <n> --json commits,files` for GitHub's view
3. Draft a new PR body. Default structure (adapt to repo style if
   an existing template is obvious):

   ## Summary
   - 1–3 bullets covering the overall intent / outcome

   ## Changes
   - Bullet per logical change, grouped by area when useful;
     reference notable files as `path/to/file.ext:LINE` when it
     aids review

   ## Notes
   - Migration steps, follow-ups, risks, or anything reviewers
     should know. Omit the section if there's nothing to say.

   Rules:
   - Cover EVERY commit in the PR, not only the most recent
   - Imperative voice, present tense, no marketing language
   - Do NOT invent changes; if a commit is unclear, inspect its
     diff before describing it
   - Preserve any "Closes #123" / "Fixes #123" trailers that
     already exist in the PR body or commit messages
4. Show the proposed body to the user and ask for confirmation
   before updating, unless they have already approved in this
   session.
5. Update the PR with `gh pr edit <n> --body-file -` (pass the
   new body via stdin / heredoc to preserve formatting). Do NOT
   change the title unless the user asked for it.
6. Print the PR URL when done.
