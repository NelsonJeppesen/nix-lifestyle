# Neovim Cheatsheet

Personal reference for the Neovim setup defined in `home-manager/neovim.nix`.
Only includes non-obvious keys and the AI/agent integrations — vanilla vim
motions are assumed.

`<leader>` is `<Space>` (mini.basics default).

---

## opencode.nvim (AI agent)

Plugin: <https://github.com/nickjvandyke/opencode.nvim>
Config: `home-manager/neovim.nix:519` · WhichKey group: `<leader>o`

### Mental model

The plugin is a **wrapper around the `opencode` TUI**, not a separate AI
client. It spawns (or attaches to) an `opencode` process in a terminal split
and pipes prompts into it. The plugin's job is to:

1. Open a nice input box (snacks.input) for you to type a prompt.
2. Substitute `@…` placeholders with editor context.
3. Send the prompt to opencode.
4. Reload buffers when opencode edits files; show diffs for approval.

> **Save your buffer before asking.** opencode reads files from disk —
> unsaved changes are invisible to it.

### Keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>oa` | n, x | **Ask** — input prompt, pre-filled with `@this: `, submits on `<CR>`. Press `<Up>` for recent prompts. End the prompt with a space to append instead of submit. |
| `<leader>ox` | n, x | **Select** — pick a built-in prompt (`explain`, `fix`, `test`, `implement`, `optimize`, `review`, `document`, `diagnostics`, `diff`) or a session/server command. |
| `<leader>op{motion}` | n, x | **Operator** — add a range to opencode and dot-repeat. e.g. `<leader>opip` = inner paragraph, `<leader>op<leader>op` = current line. |
| `<leader>og` | n, t | Toggle the opencode terminal split. |
| `<leader>oc` | n | Stop the in-flight response. |
| `<leader>os` / `<leader>od` | n | Scroll opencode buffer up / down half-page. |

### Context placeholders

Substituted into the prompt before send:

| Placeholder | Expands to |
|---|---|
| `@this` | Visual selection / operator range / cursor position |
| `@buffer` | Current buffer |
| `@buffers` | All open buffers |
| `@visible` | Visible text in the window |
| `@diagnostics` | Current buffer's diagnostics |
| `@quickfix` | Quickfix list |
| `@diff` | Git diff |
| `@marks` | Global marks |

### Recipes

| I want to… | Do this |
|---|---|
| Implement a stub | Visual-select stub → `<leader>oa` → `implement @this` |
| Add tests | Cursor on function → `<leader>ox` → pick `test` |
| Fix a diagnostic | Cursor on the line → `<leader>ox` → pick `fix` |
| Explain code | Visual-select → `<leader>ox` → `explain` |
| Code review the diff | `<leader>ox` → `diff` |
| Free-form question | `<leader>oa` |
| Send a paragraph as context, type instruction myself | `<leader>opip` then type instruction |
| Stop a runaway response | `<leader>oc` |

### Reviewing AI edits

When opencode wants to edit a file, the plugin opens a diff tab:

| Key | Action |
|---|---|
| `da` | Accept the entire edit request |
| `dr` | Reject the entire edit request |
| `dp` | Accept only the hunk under the cursor (rejects rest) |
| `do` | Reject only the hunk under the cursor (rejects rest) |
| `]c` / `[c` | Next / prev change |
| `q` | Close the diff |

### Embedded opencode terminal (when toggled visible)

Inside the opencode terminal split, normal-mode:

| Key | Action |
|---|---|
| `<C-u>` / `<C-d>` | Scroll half page up / down |
| `gg` / `G` | First / last message |
| `<Esc>` | Interrupt response |

### Troubleshooting

- `:checkhealth opencode` — first stop for any "is it wired up?" question.
- `<leader>oa` shows a tiny single-line input with no completion → snacks
  `input` module is disabled. Should be on in `neovim.nix`.
- "No session found" → run `<leader>og` once to spawn one, or `:lua require('opencode').toggle()`.
- Notification `opencode: idle` fires when the agent finishes a response
  (autocmd on `OpencodeEvent:session.idle`).

---

## Notes / scratch buffer

Bare `nvim` (no args) opens a markdown scratch buffer at
`./.notes/scratch-<hex>.md` in the cwd, in insert mode. The directory is
created lazily on first `:write` and is gitignored repo-wide.

---

## Other AI/completion

- **GitHub Copilot** ghost-text: provided by `copilot.lua` (suggestion mode
  off by default; surfaced through `blink.cmp` + `blink-copilot`).
- **MCP servers** (memory, github, atlassian, …): only available inside
  `opencode` itself — not exposed to nvim. See `home-manager/opencode.nix`.
