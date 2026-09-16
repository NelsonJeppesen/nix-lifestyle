# Neovim Cheatsheet

Reference for `home-manager/neovim/nvf.nix`. Settings are explicit Nix options;
nvf provides the plugins and default mappings. Use `:map` to inspect active
mappings and `nvf-print-config` to inspect the generated configuration.

`<leader>` is `<Space>`. `nvim`, `vim` and `vi` are the same binary.
`nvf-print-config` prints the generated `init.lua`, `nvf-print-config-path`
its store path.

## Leader map

### `<leader>f` — find (Telescope)

| Key | Action |
| --- | --- |
| `<leader>ff` / `<leader>fg` | Find files / live grep |
| `<leader>fb` / `<leader>fh` | Buffers / help tags |
| `<leader>fp` / `<leader>fr` | Projects / resume last picker |
| `<leader>fs` / `<leader>ft` | Treesitter symbols / open picker |
| `<leader>fld` | Diagnostics |
| `<leader>flD` / `<leader>fli` / `<leader>flr` / `<leader>flt` | LSP definitions / implementations / references / type definitions |
| `<leader>flsb` / `<leader>flsw` | LSP document / workspace symbols |
| `<leader>fvf` / `<leader>fvs` / `<leader>fvb` | Git files / status / branches |
| `<leader>fvcw` / `<leader>fvcb` / `<leader>fvx` | Git commits / buffer commits / stash |

### `<leader>b` — buffers

| Key | Action |
| --- | --- |
| `<leader>bn` / `<leader>bp` | Next / previous buffer |
| `<leader>bc` | Pick a buffer |
| `<leader>bmn` / `<leader>bmp` | Move buffer forward / back |
| `<leader>bsd` / `<leader>bse` / `<leader>bsi` | Sort buffers by directory / extension / id |

### `<leader>h` — git hunks (gitsigns), and hop

| Key | Action |
| --- | --- |
| `<leader>hs` / `<leader>hS` | Stage hunk / buffer |
| `<leader>hr` / `<leader>hR` | Reset hunk / buffer |
| `<leader>hu` / `<leader>hP` | Undo stage hunk / preview hunk |
| `<leader>hb` | Blame line |
| `<leader>hd` / `<leader>hD` | Diff this / diff project |
| `<leader>h` | Jump to occurrences (hop.nvim) |

### `<leader>g` — git (Neogit, lazygit)

| Key | Action |
| --- | --- |
| `<leader>gs` / `<leader>gc` | Status / commit |
| `<leader>gp` / `<leader>gP` | Pull / push |
| `<leader>gg` | Open lazygit in a terminal |

### `<leader>c` — merge conflicts

| Key | Action |
| --- | --- |
| `<leader>co` / `<leader>ct` | Choose ours / theirs |
| `<leader>cb` / `<leader>c0` | Choose both / none |

### `<leader>l` and `<leader>x` — diagnostics (Trouble)

| Key | Action |
| --- | --- |
| `<leader>ld` / `<leader>lwd` | Document / workspace diagnostics |
| `<leader>lr` | LSP references |
| `<leader>xq` / `<leader>xl` / `<leader>xs` | Quickfix / loclist / symbols |
| `<leader>lvt` / `<leader>lvu` | Toggle / refresh the docs view panel |
| `<leader>lo` | Activate LSP at the cursor (otter.nvim, embedded code) |

### `<leader>t` — toggles and todo comments

| Key | Action |
| --- | --- |
| `<leader>tb` / `<leader>td` | Toggle git blame / deleted lines |
| `<leader>tdt` / `<leader>tds` / `<leader>tdq` | Todo comments in Trouble / Telescope / quickfix |

### `<leader>d` — debugger (nvim-dap)

| Key | Action |
| --- | --- |
| `<leader>db` / `<leader>dc` | Toggle breakpoint / continue |
| `<leader>dgj` / `<leader>dgk` | Step over / back |
| `<leader>dgi` / `<leader>dgo` / `<leader>dgc` | Step into / out / to cursor |
| `<leader>du` / `<leader>dr` | Toggle DAP UI / REPL |
| `<leader>dh` / `<leader>dq` / `<leader>dR` | Hover / terminate / restart |

### Other

| Key | Action |
| --- | --- |
| `<leader>ss` / `<leader>sS` | Leap forward / backward |
| `<leader>sx` / `<leader>sX` | Leap till forward / backward |
| `<leader>mcs` / `<leader>mcp` | Multicursor from selection / pattern |
| `<leader>h` `j` `k` `l` (with Space) | Swap buffer left / down / up / right |

## Outside the leader

| Keys | Owner | Notes |
| --- | --- | --- |
| `<C-hjkl>` | smart-splits | Move between windows and panes, `<C-\>` to the previous one |
| `<M-hjkl>` | smart-splits | Resize the current window |
| `<C-t>` | toggleterm | Floating terminal |
| `]c` / `[c` | gitsigns | Next / previous hunk |
| `]d` / `[d` / `]D` / `[D` | built-in | Next / previous / last / first diagnostic |
| `]q` `]l` `]b` `]t` `]a` | built-in | Quickfix, loclist, buffer, tag and arglist motions, `[` reverses |
| `gz` / `gZ` | nvim-surround | `gz{motion}`, `gzd` delete, `gzr` replace, capitals for line-wise |
| `gc` / `gb` | comment.nvim | Line and block comments, `gcc` / `gbc` for the current line |
| `gr` | built-in LSP | `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition, `grx` codelens, `gO` document symbols |
| `gs` | leap | Jump from another window |
| `gx` | built-in | Open the path or URL under the cursor |
| `<M-n>` / `<M-p>` | illuminate | Next / previous reference of the word under the cursor |
| `<C-s>` | mini.basics | Save, and leave insert mode |
| `<Tab>` / `<S-Tab>` | built-in | Jump between snippet placeholders |
| `\` | mini.basics | Toggle options: `\n` number, `\r` relativenumber, `\w` wrap, `\s` spell, `\l` list, `\h` search highlight, `\c` / `\C` cursorline / column, `\d` diagnostics, `\i` ignorecase, `\b` background |
| `a` / `i` | mini.ai | Text-object prefixes in operator and visual mode, plus `an` / `in` for the next one and `al` / `il` for the last |
| `gy` / `gp` | mini.basics | Copy to and paste from the system clipboard |
| `go` / `gO` | mini.basics | Add an empty line below / above |
| `g[` / `g]` | mini.ai | Move to the left / right edge of the surrounding object |
| `gV` | mini.basics | Reselect the text just changed |
| `g/` | mini.basics | Search inside the visual selection |

Completion is blink.cmp; avante.nvim is the AI assistant and is driven by its
`:Avante*` commands rather than by keymaps.

## Languages

Enabled language modules: **Bash, Docker, dotenv, JSON, Lua, Nix, Python,
SQL, and TOML**. Formatting, Treesitter, and extra diagnostics are enabled
for these modules. Harper is also enabled for prose checking.

YAML, Ansible, Jinja, Terraform/HCL, Ruby, and Markdown language modules
are not enabled. Standalone CLI tooling remains available separately.

## Changing the configuration

`home-manager/neovim/nvf.nix` holds the whole configuration explicitly, so changing
anything means editing the option in place rather than overriding an import.
Note that mini.basics only sets an option that nothing else has set already,
so nvf's own settings win over it. Search stays case-sensitive, for instance,
because nvf sets `vim.searchCase`; `vim.searchCase = "smart"` changes that.

Rebuild with `home-manager switch --flake ~/.config/home-manager#nelson`, or
`update` for both layers.
