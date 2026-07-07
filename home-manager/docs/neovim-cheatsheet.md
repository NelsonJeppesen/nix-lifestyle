# Neovim Cheatsheet

Personal reference for the Neovim setup defined in `home-manager/neovim.nix`.
Only includes non-obvious keys and the AI/agent integrations — vanilla vim
motions are assumed.

`<leader>` is `<Space>` (mini.basics default). Arrow keys are disabled —
use `hjkl`. Bare `nvim` opens a markdown scratch buffer at
`./.notes/scratch-<hex>.md` in the cwd, in insert mode.

## Contents

- [Leader-key map](#leader-key-map)
- [opencode.nvim (AI agent)](#opencodenvim-ai-agent)
- [snacks.nvim (picker / explorer / input / terminal)](#snacksnvim-picker--explorer--input--terminal)
- [LSP & diagnostics](#lsp--diagnostics)
- [trouble.nvim & todo-comments.nvim](#troublenvim--todo-commentsnvim)
- [blink.cmp & Copilot](#blinkcmp--copilot)
- [oil.nvim (filesystem-as-buffer)](#oilnvim-filesystem-as-buffer)
- [Git (gitsigns / headhunter)](#git-gitsigns--headhunter)
- [treesitter & textobjects](#treesitter--textobjects)
- [mini.\* family](#mini-family)
- [nvim-various-textobjs](#nvim-various-textobjs)
- [Surround (mini.surround)](#surround-minisurround)
- [treewalker.nvim (AST navigation)](#treewalkernvim-ast-navigation)
- [hardtime.nvim](#hardtimenvim)
- [toggleterm.nvim](#toggletermnvim)
- [bufferline / lualine / navic / fidget / noice](#bufferline--lualine--navic--fidget--noice)
- [Theme (tokyonight + GNOME sync)](#theme-tokyonight--gnome-sync)
- [Eye candy (tiny-glimmer / tiny-inline-diagnostic / mini.animate)](#eye-candy)
- [Util commands (`<leader>u…`)](#util-commands-leaderu)
- [vim-table-mode](#vim-table-mode)
- [Quirks & gotchas](#quirks--gotchas)

---

## Leader-key map

WhichKey groups (popup appears after `<Space>` + delay):

| Key | Group | What lives there |
|---|---|---|
| `<leader><space>` | — | Smart find files (Snacks picker) |
| `<leader>,` | — | Buffer list |
| `<leader>/` | — | Project grep |
| `<leader>:` | — | Command history |
| `<leader>n` | — | Notification history |
| `<leader>e` | — | Open Oil at cwd |
| `<leader>?` | — | Show all keybindings |
| `<leader>f` | Find | files / buffers / config / git files / projects / recent |
| `<leader>s` | Search/Grep | grep / lines / registers / jumps / marks / undo / etc. |
| `<leader>l` | LSP | goto / refs / rename / code action / format / diagnostics |
| `<leader>x` | Diagnostics | trouble.nvim views |
| `<leader>g` | Git | branches / log / status / diff |
| `<leader>gm` | Merge | headhunter merge-conflict resolution |
| `<leader>o` | OpenCode | AI agent (see dedicated section) |
| `<leader>q` | Quit | `q` / `qa` / `qa!` |
| `<leader>w` | Write | `w` / `wq` |
| `<leader>u` | Util | base64/jq/copy buffer/colorscheme/table mode |
| `\…` | Toggle | option toggles (cursorline / number / wrap / git blame / …) |

Config: `home-manager/neovim/lua/which-key-nvim.lua`

---

## opencode.nvim (AI agent)

Plugin: <https://github.com/nickjvandyke/opencode.nvim>
Config: `home-manager/neovim.nix:529` · WhichKey group: `<leader>o`

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
| Multi-send picker results | In any Snacks picker → toggle entries → `<a-a>` |

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

## snacks.nvim (picker / explorer / input / terminal)

Plugin: <https://github.com/folke/snacks.nvim>
Config: `home-manager/neovim.nix:408`

Only `picker`, `explorer`, `terminal`, and `input` modules are enabled.
Most leader-key bindings under `<leader>f`, `<leader>s`, `<leader>g`, and
LSP goto-* under `<leader>l` are Snacks pickers.

### In any picker

| Key | Action |
|---|---|
| `<CR>` | Open / confirm |
| `<C-x>` / `<C-v>` / `<C-t>` | Open in split / vsplit / tab |
| `<C-q>` | Send results to quickfix |
| `<Tab>` | Toggle selection (multi-select) |
| `<a-a>` | Multi-send selected items into opencode |
| `<C-d>` / `<C-u>` | Half-page down / up in preview |
| `?` | Show picker-specific keymaps |

### Quick access

| Key | Action |
|---|---|
| `<leader><space>` | **Smart find** — combines files, buffers, recents |
| `<leader>,` | Buffers |
| `<leader>/` | Project-wide grep |
| `<leader>:` | Command history |
| `<leader>n` | Notification history |

### `<leader>f` Find

`fb` buffers · `fc` config files (`stdpath("config")`) · `ff` files ·
`fg` git files · `fp` projects · `fr` recent

### `<leader>s` Search/Grep (the kitchen sink)

| Key | Picker |
|---|---|
| `sb` / `sB` | Buffer lines / Grep open buffers |
| `sg` / `sw` | Grep / Grep word under cursor |
| `s"` | Registers |
| `s/` / `sc` / `sC` | Search history / Cmd history / Commands |
| `sa` | Autocmds |
| `sd` / `sD` | Diagnostics (workspace / buffer) |
| `sh` / `sM` | Help / man pages |
| `sH` / `si` | Highlights / Icons |
| `sj` / `sm` | Jumps / Marks |
| `sk` | Keymaps |
| `sl` / `sq` | Loclist / Quickfix |
| `sp` | Plugin specs (lazy.nvim view) |
| `sR` | Resume last picker |
| `su` | Undo history (browse undotree as a picker) |

### Snacks terminal

Used internally by opencode.nvim. Direct toggle is `<C-\>` (toggleterm,
not snacks) — keep them separate, snacks-terminal is for plugin use.

---

## LSP & diagnostics

Config: `home-manager/neovim.nix:338` (lspconfig) · servers in
`extraPackages` at `home-manager/neovim.nix:23`.

Enabled servers: `bashls`, `jsonls`, `nixd`, `ruby_lsp`,
`terraformls`, `typos_lsp`, `yamlls`. Diagnostics are
rendered by tiny-inline-diagnostic.nvim — built-in `virtual_text` /
`virtual_lines` are off to avoid double display.

### `<leader>l` group (Snacks-backed pickers)

| Key | Action |
|---|---|
| `li` | `:LspInfo` |
| `ld` / `lD` | Definition / Declaration |
| `lI` / `ly` | Implementation / Type definition |
| `lr` | References |
| `ls` / `lS` | Document / Workspace symbols |
| `lR` | Rename (`vim.lsp.buf.rename`) |
| `la` | Code action (n + v) |
| `lf` | Format (conform.nvim, LSP fallback; nixfmt for `.nix`, shfmt for `sh/bash`) |
| `ln` / `lp` | Next / prev diagnostic (with float) |

### Built-in `gr*` (Neovim 0.11+ defaults)

`grn` rename · `gra` code action · `grr` references · `gri` implementation · `K` hover

### Diagnostic icons

`` error · `` warn · `` info · `󰌵` hint (Nerd Font required).

---

## trouble.nvim & todo-comments.nvim

Config: `home-manager/neovim.nix:365` (trouble), `:374` (todo)

| Key | View |
|---|---|
| `<leader>xx` | Workspace diagnostics |
| `<leader>xX` | Buffer diagnostics |
| `<leader>xs` | Symbols (focus stays on code) |
| `<leader>xl` / `<leader>xq` | Location list / quickfix |
| `<leader>xt` | TODO/FIXME/HACK/NOTE comments |

Inside the trouble window: `]t` / `[t` next/prev todo comment,
`<CR>` jump, `q` close, `r` refresh, `P` toggle preview.

---

## blink.cmp & Copilot

Config: `home-manager/neovim.nix:602` (blink), `:587` (copilot.lua)

Sources, in priority order: **copilot** (score_offset 100) → LSP → path →
snippets → buffer. Copilot ghost text is shown via blink (suggestion mode
in `copilot.lua` itself is **off** to avoid double suggestions).

| Key | Mode | Action |
|---|---|---|
| `<C-a>` | i | Accept selected completion |
| `<C-n>` / `<C-p>` | i | Next / prev completion |
| `<C-Space>` | i | Open menu manually |
| `<C-y>` | i | Disabled (cleared to free the binding) |
| `<C-e>` | i | Cancel/hide menu |
| `<Tab>` | i | Snippet jump forward |
| `<S-Tab>` | i | Snippet jump backward |

Documentation popup auto-shows after 100ms; signature help is on with a
rounded border.

---

## oil.nvim (filesystem-as-buffer)

Plugin: <https://github.com/stevearc/oil.nvim>
Config: `home-manager/neovim.nix:247`

Open with `<leader>e` or `:Oil`. The buffer **is** the directory — edit it
like text, `:w` to apply.

| Key | Action |
|---|---|
| `<CR>` | Open file / cd into dir |
| `-` | Go up a directory |
| `_` | Open cwd |
| `g?` | Help (full keymap list) |
| `gs` | Change sort order |
| `g.` | Toggle hidden files |
| `gx` | Open with system handler |
| `<C-s>` / `<C-h>` / `<C-t>` | Open in vsplit / split / tab |
| `<C-p>` | Preview |
| `<C-c>` | Close oil |
| `<C-l>` | Refresh |

Edits stage as a diff; `:w` previews then commits. git status indicators
in the sign column come from `oil-git-status-nvim`.

---

## Git (gitsigns / headhunter)

Config: `home-manager/neovim.nix:749` (gitsigns), `:757` (headhunter)

### `<leader>g` Git pickers (Snacks)

| Key | Action |
|---|---|
| `gb` / `gl` / `gL` | Branches / Log / Log for current line |
| `gs` / `gS` | Status / Stash |
| `gd` | Diff (hunks) |
| `gf` | Log for current file |

### gitsigns (sign column)

`\g` toggle current-line blame · `\G` full blame buffer.
Hunk navigation/staging via `:Gitsigns` (no leader bindings — use the
command for one-offs).

### headhunter (merge conflicts)

| Key | Action |
|---|---|
| `]g` / `[g` | Next / prev conflict |
| `<leader>gmh` | Take HEAD |
| `<leader>gmo` | Take origin |
| `<leader>gmb` | Take both |
| `<leader>gmq` | Send all conflicts to quickfix |

---

## treesitter & textobjects

Config: `home-manager/neovim.nix:455` (parsers), `:477` (textobjects).
All grammars bundled via `withAllGrammars`. Folding is intentionally
**disabled**.

### Selection (operator + visual)

| Pair | Object |
|---|---|
| `af` / `if` | Function outer / inner |
| `ac` / `ic` | Class outer / inner |
| `ab` / `ib` | Block outer / inner |
| `aa` / `ia` | Parameter / argument |
| `ai` / `ii` | Conditional |
| `al` / `il` | Loop |

### Movement

`]f` `[f` function · `]c` `[c` class · `]b` `[b` block · `]p` `[p`
parameter · `]i` `[i` conditional · `]o` `[o` loop · `]m` `[m` call.
Capital letter = inner-end variant (`]B` block-inner-end, etc.).
All moves push to the jumplist (`set_jumps = true`).

---

## mini.* family

Each module is enabled per-feature (no monolithic setup).

### mini.basics — sane defaults
Config: `home-manager/neovim.nix:149`. Enables `options.basic` +
`extra_ui`, `mappings.basic` + `windows` + `move_with_alt`.
Bindings it provides:

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Window navigate |
| `<M-h/j/k/l>` | Move line/selection (but overridden — see treewalker) |
| `\…` | Toggle options (see leader map) |
| `go` / `gO` | Add empty line below / above |
| `<C-s>` | Save buffer (n/i/x) |

### mini.ai — extended text objects
Config: `home-manager/neovim.nix:180`. Adds treesitter-backed `o`/`f`/`c`
on top of standard targets:

| Pair | Object |
|---|---|
| `ao` / `io` | Block/conditional/loop (whichever wraps cursor) |
| `af` / `if` | Function (treesitter) |
| `ac` / `ic` | Class (treesitter) |
| `aq` / `iq` | Quote (any of `"'``) |
| `ab` / `ib` | Bracket (any of `()[]{}`) |
| `a?` / `i?` | User-prompt (asks for left/right delimiter) |

`n_lines = 500` so it scans up to 500 lines for matches.

### mini.surround
See dedicated section below.

### mini.animate
Config: `home-manager/neovim.nix:853`. Smooth scroll + window resize
animations (cursor animation disabled — smear-cursor removed; open/close
disabled to avoid fighting noice/snacks).

---

## nvim-various-textobjs

Plugin: <https://github.com/chrisgrieser/nvim-various-textobjs>
Config: `home-manager/neovim.nix:203`. `useDefaults = true`.

Most-used:

| Pair | Object |
|---|---|
| `ai` / `ii` | Around / inside indent block |
| `av` / `iv` | Value (after `=` or `:`) — config files |
| `ak` / `ik` | Key (before `=` or `:`) |
| `aS` / `iS` | Subword (camelCase / snake_case parts) |
| `gG` | Entire buffer (operator) |
| `gc` | Inside comment (operator) |
| `!!` / `!` | Diagnostic on line / under cursor |
| `am` / `im` | Chain member (`.foo()`) |
| `aR` / `iR` | REST request (HTTP block) |
| `iU` / `aU` | URL |

---

## Surround (mini.surround)

Plugin: <https://github.com/echasnovski/mini.surround>
Config: `home-manager/neovim.nix:170`. `s` is the prefix (overrides
default vim `s` — substitute char).

| Key | Action |
|---|---|
| `sa{motion}{char}` | Add surround |
| `sd{char}` | Delete surround |
| `sr{old}{new}` | Replace surround |
| `sf{char}` | Find right (next surround) |
| `sF{char}` | Find left (prev surround) |
| `sh{char}` | Highlight surround |
| `sn` | Update `n_lines` for this session |

Examples: `saiw"` quote a word · `sd"` strip surrounding quotes ·
`sr({` swap parens for braces.

---

## treewalker.nvim (AST navigation)

Plugin: <https://github.com/aaronik/treewalker.nvim>
Config: `home-manager/neovim.nix:218`

| Key | Action |
|---|---|
| `<M-h/j/k/l>` | Move sibling/parent/child in AST (n + v) |
| `<M-S-j>` / `<M-S-k>` | Swap node down / up (n) |

Use this to skip past blocks of similar code without counting lines.

---

## hardtime.nvim

Config: `home-manager/neovim.nix:252` (hardtime)

**hardtime** punishes repeated `hjkl` / `wb` spam — forces `f`/`t`/`/`/
relative line jumps. If a key feels blocked, look at the corner notification
for a hint. Disable for a buffer with `:Hardtime disable`.

---

## toggleterm.nvim

Plugin: <https://github.com/akinsho/toggleterm.nvim>
Config: `home-manager/neovim.nix:754`. Floating terminal, curved border,
3% winblend.

| Key | Mode | Action |
|---|---|---|
| `<C-\>` | n, i, t | Toggle floating terminal |

Inside the terminal: prefix any vim command with `<C-\><C-n>` to exit
to normal mode (terminal-mode default).

---

## bufferline / lualine / navic / fidget / noice

| Plugin | Role | Notable |
|---|---|---|
| `bufferline-nvim` | Buffer tabs at top | No icons, no close icons, thick separators. Use `:bnext`/`:bprev` or `<leader>,` picker to switch. |
| `lualine-nvim` | Statusline | Auto-themes off colorscheme. |
| `nvim-navic` | Winbar breadcrumbs | Auto-attaches to LSP servers with `documentSymbolProvider`. Click breadcrumbs to jump. |
| `fidget-nvim` | LSP progress (bottom-right) | Replaces noice's progress popups. |
| `noice-nvim` | Cmdline UI | Only the cmdline popup is on; messages/notify/popupmenu/lsp.* all disabled. |

---

## Theme (tokyonight + GNOME sync)

Config: `home-manager/neovim.nix` (tokyonight + auto-dark-mode.nvim blocks)

`auto-dark-mode.nvim` watches the system light/dark preference via the
`org.freedesktop.appearance.color-scheme` xdg-desktop-portal D-Bus (the
same source kitty uses) and switches the colorscheme on change:

- dark  → `tokyonight-night` (`background=dark`)
- light → `tokyonight-day` (`background=light`)

Switch your GNOME theme — Neovim follows within a few seconds (no
refocus needed; polled every 3s). On a tty/SSH session where the portal
is unavailable it falls back to dark. Devicon colors re-tint via
`tiny-devicons-auto-colors-nvim` on the `ColorScheme` autocmd, so icons
stay readable across the switch.

Manual override: `:colorscheme <name>` or `<leader>uC` to pick.

---

## Eye candy

Mostly visual; can be disabled by toggling the relevant `enabled` field
in `neovim.nix`.

| Plugin | What it animates / shows |
|---|---|
| `tiny-glimmer-nvim` | Yank (fade) / paste (reverse fade) / search (pulse) / undo (red fade) / redo (green fade). Disabled in `oil` and `snacks_dashboard` buffers. |
| `tiny-inline-diagnostic-nvim` | Inline LSP diagnostic with arrow → offending column. `modern` preset. Hidden while in insert mode. |
| `mini-animate` | Smooth scroll (120ms linear) + window resize (100ms). |
| `numb-nvim` | Peek line target while typing `:42` (before pressing Enter). |
| `vim-illuminate` | Highlights other occurrences of the word under cursor. |
| `cellular-automaton-nvim` | `<leader>fml` → "make it rain" your buffer. Pure dopamine. |

---

## Util commands (`<leader>u…`)

Config: `home-manager/neovim/lua/which-key-nvim.lua:127`

| Key | Action |
|---|---|
| `uc` | Copy entire buffer to system clipboard (`%y+`) |
| `ub` | Decode base64 (`%!base64 -d`) |
| `ug` | Decode base64-gzip (`%!base64 -d \| gzip -d`) |
| `uj` | Format JSON via `jq .` |
| `uC` | Pick a colorscheme |
| `ut` / `ur` | Table mode toggle / realign |

---

## vim-table-mode

Plugin: <https://github.com/dhruvasagar/vim-table-mode>
Config: `home-manager/neovim.nix:907`. Default mappings disabled — use
`<leader>ut` to toggle, then type pipes.

| Key | Action |
|---|---|
| `<leader>ut` | Toggle table-mode |
| `<leader>ur` | Realign existing table |
| `\t` | Same as `<leader>ut` (via `\` toggle group) |
| `||` (in insert) | Insert a header separator |

Corner char `\|`, header fill `-` (markdown-friendly).

---

## Quirks & gotchas

- **Arrow keys do nothing** in insert/visual; in normal mode they echo
  a complaint. Use `hjkl` (or `hardtime` will yell anyway).
- **`vim.lsp.log` is errors-only** — if you need protocol traces, bump
  `vim.lsp.log.set_level("DEBUG")` at runtime.
- **Save before opencode.** It reads from disk, not from the buffer.
- **`s` is mini.surround**, not vim's `s` (substitute char). Use `cl`
  for the old behavior.
- **`<leader>op…` is opencode operator**, not "previous". Treesitter
  prev-* lives on `[`.
- **Folding is off everywhere.** The treesitter setup intentionally
  doesn't set `foldexpr`. If you want it, edit `neovim.nix:455`.
- **Bare `nvim`** drops you into a scratch markdown file under
  `.notes/` in the cwd. The dir is created lazily on first `:w` and
  is gitignored. Pipe into nvim or pass an arg to skip this.
- **MCP servers** (memory, github, atlassian, …): only available inside
  `opencode` itself — not exposed to nvim. See
  `home-manager/opencode.nix`.
- **Copilot ghost text** comes from `blink.cmp`, not `copilot.lua`'s
  built-in suggestion mode (which is off).
