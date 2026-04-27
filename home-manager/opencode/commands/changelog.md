# Update Changelog

Generate a new CHANGELOG.md release entry from the commits since the
last release tag, then prepend it to CHANGELOG.md.

Argument (optional): version bump or explicit version.
  - `patch` / `minor` / `major` → bump from the last semver tag
  - explicit version like `1.4.0` or `v1.4.0` → use as-is
  - omitted → infer from commit messages (Conventional Commits if
    present: `feat:` ⇒ minor, `fix:`/`perf:`/`refactor:` ⇒ patch,
    `BREAKING CHANGE` or `feat!:` ⇒ major; otherwise ask)

Steps:
1. Discover repo state (run in parallel):
   - `git describe --tags --abbrev=0` → last tag (`<base>`); if no
     tags exist, treat the initial commit as the base and warn
   - `git log <base>..HEAD --reverse --pretty=format:'%H%x09%s%x09%b%x1e'`
     → every new commit (subject + body, NUL-style separated)
   - `git diff <base>...HEAD --stat` → high-level change map
   - `cat CHANGELOG.md` if it exists, else plan to create one with a
     Keep-a-Changelog header
2. Compute the new version:
   - Resolve `$ARGUMENTS` per the rules above
   - Print the chosen version and the reasoning, then proceed
3. Group commits into Keep-a-Changelog sections by inspecting the
   subject (and body when needed):
     ### Added       — new features (`feat:`, "add", "introduce")
     ### Changed     — behavior changes that aren't fixes
     ### Deprecated  — soon-to-be-removed features
     ### Removed     — deletions
     ### Fixed       — bug fixes (`fix:`, "fix", "correct")
     ### Security    — vulnerability/security fixes
   Skip noise (merge commits, pure formatting/`chore:`/`ci:`/`docs:`
   commits) unless they're user-visible. If a commit is ambiguous,
   open its diff before deciding.
4. Draft the new entry. Format:

   ## [<version>] - <YYYY-MM-DD>

   ### Added
   - <imperative bullet> (<short-sha>)
   ...

   Rules:
   - Imperative, present tense, no marketing language
   - One bullet per logical change; collapse "fix typo + lint" type
     noise
   - Reference notable files as `path/to/file.ext:LINE` when it
     aids the reader
   - Preserve any `Closes #123` / `Fixes #123` trailers as
     `(#123)` at the end of the bullet
   - Omit empty sections
5. Show the proposed entry to the user for confirmation, unless
   they have already approved in this session.
6. Write the file:
   - If CHANGELOG.md exists: insert the new entry directly under the
     top header (typically after the `# Changelog` line and any
     intro paragraph), above the previous most-recent release
   - If it doesn't exist: create it with the standard
     Keep-a-Changelog preamble followed by the new entry
   - Update / add the comparison links footer when the repo already
     uses them (e.g. `[<version>]: https://…/compare/<base>...v<version>`)
7. Print a short summary: new version, # of commits included, and
   the path(s) modified. Do NOT create a git tag, commit, or push —
   leave that to the user (or to `/commit-and-push`).

Refuse and explain if:
- The working tree is dirty in a way that would make the diff
  ambiguous (uncommitted changes to CHANGELOG.md itself)
- There are zero new commits since `<base>`
