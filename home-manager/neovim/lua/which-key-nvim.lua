local wk = require("which-key")
require("which-key").setup {
   win = {
     border = "rounded",
     padding = { 1, 2, 1, 2 },
     no_overlap = false,
   },
   triggers = {
     { "<auto>", mode = "nxsot" },
     { "s", mode = { "n", "x" } },
   },
}

wk.add({
  -- Quick access bindings
  { 'q', desc = "precognition peek", function() require("precognition").peek() end},
  { '<c-\\>', desc = "Toggle Terminal", function() require("toggleterm").toggle() end, mode = { "n", "i", "t" } },

  { "<leader>fml", desc = "FML" ,"<cmd>CellularAutomaton make_it_rain<cr>"},

  -- Top-level leader shortcuts
  { "<leader><space>", desc = "Smart Find Files", function() Snacks.picker.smart() end },
  { "<leader>,", desc = "Buffers", function() Snacks.picker.buffers() end },
  { "<leader>/", desc = "Grep", function() Snacks.picker.grep() end },
  { "<leader>:", desc = "Command History", function() Snacks.picker.command_history() end },
  { "<leader>n", desc = "Notification History", function() Snacks.picker.notifications() end },
  { "<leader>e", desc = "Oil", "<cmd>Oil<cr>" },
  { "<leader>?", desc = "keybindings", function() require("which-key").show() end },

  -- Quit group
  { "<leader>q", group = "Quit" },
  { "<leader>qq", desc = "Quit", "<cmd>q<cr>" },
  { "<leader>qa", desc = "Quit All", "<cmd>qa<cr>" },
  { "<leader>qf", desc = "Quit [force]", "<cmd>qa!<cr>" },

  -- Write group
  { "<leader>w", group = "Write" },
  { "<leader>wq", desc = "Write Quit", "<cmd>wq<cr>" },
  { "<leader>ww", desc = "Write", "<cmd>w<cr>" },

  -- OpenCode AI integration group
  { "<leader>o", group = "OpenCode" },

  -- Diagnostics group (trouble.nvim)
  { "<leader>x", group = "Diagnostics" },
  { "<leader>xx", desc = "Diagnostics (Trouble)", "<cmd>Trouble diagnostics toggle<cr>" },
  { "<leader>xX", desc = "Buffer Diagnostics", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>" },
  { "<leader>xs", desc = "Symbols (Trouble)", "<cmd>Trouble symbols toggle focus=false<cr>" },
  { "<leader>xl", desc = "Location List", "<cmd>Trouble loclist toggle<cr>" },
  { "<leader>xq", desc = "Quickfix List", "<cmd>Trouble qflist toggle<cr>" },
  { "<leader>xt", desc = "Todo Comments", "<cmd>Trouble todo toggle<cr>" },

  -- LSP group: language server interactions
  { "<leader>l", group = "LSP" },
  { "<leader>li", desc = "LSP Info", "<cmd>LspInfo<cr>" },
  { "<leader>lD", desc = "Goto Declaration", function() Snacks.picker.lsp_declarations() end },
  { "<leader>lI", desc = "Goto Implementation", function() Snacks.picker.lsp_implementations() end },
  { "<leader>ld", desc = "Goto Definition", function() Snacks.picker.lsp_definitions() end },
  -- <leader>lf is registered by conform.nvim (formatter with LSP fallback)
  { "<leader>lr", desc = "References", function() Snacks.picker.lsp_references() end, nowait = true },
  { "<leader>ly", desc = "Goto T[y]pe Definition", function() Snacks.picker.lsp_type_definitions() end },
  { "<leader>ls", desc = "LSP Symbols", function() Snacks.picker.lsp_symbols() end },
  { "<leader>lS", desc = "LSP Workspace Symbols", function() Snacks.picker.lsp_workspace_symbols() end },
  { "<leader>lR", desc = "Rename", vim.lsp.buf.rename },
  { "<leader>la", desc = "Code Action", vim.lsp.buf.code_action, mode = { "n", "v" } },
  { "<leader>ln", desc = "Next Diagnostic", function() vim.diagnostic.jump({ count = 1, float = true }) end },
  { "<leader>lp", desc = "Prev Diagnostic", function() vim.diagnostic.jump({ count = -1, float = true }) end },

  -- Find group: file and buffer navigation
  { "<leader>f", group = "Find" },
  { "<leader>fb", desc = "Buffers", function() Snacks.picker.buffers() end },
  { "<leader>fc", desc = "Find Config File", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
  { "<leader>ff", desc = "Find Files", function() Snacks.picker.files() end },
  { "<leader>fg", desc = "Find Git Files", function() Snacks.picker.git_files() end },
  { "<leader>fp", desc = "Projects", function() Snacks.picker.projects() end },
  { "<leader>fr", desc = "Recent", function() Snacks.picker.recent() end },

  -- Git group: git operations via snacks picker
  { "<leader>g", group = "Git" },
  { "<leader>gb", desc = "Git Branches", function() Snacks.picker.git_branches() end },
  { "<leader>gl", desc = "Git Log", function() Snacks.picker.git_log() end },
  { "<leader>gL", desc = "Git Log Line", function() Snacks.picker.git_log_line() end },
  { "<leader>gs", desc = "Git Status", function() Snacks.picker.git_status() end },
  { "<leader>gS", desc = "Git Stash", function() Snacks.picker.git_stash() end },
  { "<leader>gd", desc = "Git Diff (Hunks)", function() Snacks.picker.git_diff() end },
  { "<leader>gf", desc = "Git Log File", function() Snacks.picker.git_log_file() end },
  { "<leader>gD", desc = "Diffview Open", "<cmd>DiffviewOpen<cr>" },
  { "<leader>gc", desc = "Diffview Close", "<cmd>DiffviewClose<cr>" },
  { "<leader>gh", desc = "Diffview File History", "<cmd>DiffviewFileHistory %<cr>" },

  -- Merge conflicts (headhunter.nvim)
  { "<leader>gm", group = "Merge Conflicts" },
  { "<leader>gmh", desc = "Take HEAD",   "<cmd>HeadhunterTakeHead<cr>" },
  { "<leader>gmo", desc = "Take Origin", "<cmd>HeadhunterTakeOrigin<cr>" },
  { "<leader>gmb", desc = "Take Both",   "<cmd>HeadhunterTakeBoth<cr>" },
  { "<leader>gmq", desc = "Quickfix Conflicts", "<cmd>HeadhunterQuickfix<cr>" },
  { "]g", desc = "Next Conflict" },
  { "[g", desc = "Previous Conflict" },

  -- Search/Grep group: content search and exploration
  { "<leader>s", group = "Search/Grep" },
  { "<leader>sb", desc = "Buffer Lines", function() Snacks.picker.lines() end },
  { "<leader>sB", desc = "Grep Open Buffers", function() Snacks.picker.grep_buffers() end },
  { "<leader>sg", desc = "Grep", function() Snacks.picker.grep() end },
  { "<leader>sw", desc = "Visual selection", function() Snacks.picker.grep_word() end, mode = { "n", "x" } },
  { '<leader>s"', desc = "Registers", function() Snacks.picker.registers() end },
  { '<leader>s/', desc = "Search History", function() Snacks.picker.search_history() end },
  { "<leader>sa", desc = "Autocmds", function() Snacks.picker.autocmds() end },
  { "<leader>sc", desc = "Command History", function() Snacks.picker.command_history() end },
  { "<leader>sC", desc = "Commands", function() Snacks.picker.commands() end },
  { "<leader>sd", desc = "Diagnostics", function() Snacks.picker.diagnostics() end },
  { "<leader>sD", desc = "Buffer Diagnostics", function() Snacks.picker.diagnostics_buffer() end },
  { "<leader>sh", desc = "Help Pages", function() Snacks.picker.help() end },
  { "<leader>sH", desc = "Highlights", function() Snacks.picker.highlights() end },
  { "<leader>si", desc = "Icons", function() Snacks.picker.icons() end },
  { "<leader>sj", desc = "Jumps", function() Snacks.picker.jumps() end },
  { "<leader>sk", desc = "Keymaps", function() Snacks.picker.keymaps() end },
  { "<leader>sl", desc = "Location List", function() Snacks.picker.loclist() end },
  { "<leader>sm", desc = "Marks", function() Snacks.picker.marks() end },
  { "<leader>sM", desc = "Man Pages", function() Snacks.picker.man() end },
  { "<leader>sp", desc = "Search for Plugin Spec", function() Snacks.picker.lazy() end },
  { "<leader>sq", desc = "Quickfix List", function() Snacks.picker.qflist() end },
  { "<leader>sR", desc = "Resume", function() Snacks.picker.resume() end },
  { "<leader>su", desc = "Undo History", function() Snacks.picker.undo() end },

  -- Util group: buffer operations and formatting
  { "<leader>u", group = "Util" },
  { "<leader>uc", desc = "Copy Buffer", "<cmd>%y+<cr>" },
  { "<leader>ub", desc = "Decode Base64", "<cmd>%!base64 -d<cr>" },
  { "<leader>ug", desc = "Decode Base64-gzip", "<cmd>%!base64 -d|gzip -d<cr>" },
  { "<leader>uj", desc = "Format JSON", "<cmd>%!jq .<cr>" },
  { "<leader>uC", desc = "Colorschemes", function() Snacks.picker.colorschemes() end },
  { "<leader>up", desc = "Precognition Toggle", function() require("precognition").toggle() end },

  { "<leader>ut", desc = "Table Mode: Toggle", "<cmd>TableModeToggle<cr>" },
  { "<leader>ur", desc = "Table Mode: Realign", "<cmd>TableModeRealign<cr>" },

  -- Textobject navigation (treesitter-textobjects)
  { "[", group = "Previous" },
  { "[B", desc = "Previous Block Inner" },
  { "[I", desc = "Previous Conditional Inner" },
  { "[M", desc = "Previous Call Inner" },
  { "[O", desc = "Previous Loop Inner" },
  { "[S", desc = "Previous Scope Inner" },
  { "[b", desc = "Previous Block Outer" },
  { "[c", desc = "Previous Class Outer" },
  { "[f", desc = "Previous Function Outer" },
  { "[i", desc = "Previous Conditional Outer" },
  { "[m", desc = "Previous Call Outer" },
  { "[o", desc = "Previous Loop Outer" },
  { "[p", desc = "Previous Parameter Inner" },
  { "[s", desc = "Previous Scope Outer" },

  { "]", group = "Next" },
  { "]B", desc = "Next Block Inner" },
  { "]I", desc = "Next Conditional Inner" },
  { "]M", desc = "Next Call Inner" },
  { "]O", desc = "Next Loop Inner" },
  { "]S", desc = "Next Scope Inner" },
  { "]b", desc = "Next Block Outer" },
  { "]c", desc = "Next Class Outer" },
  { "]f", desc = "Next Function Outer" },
  { "]i", desc = "Next Conditional Outer" },
  { "]m", desc = "Next Call Outer" },
  { "]o", desc = "Next Loop Outer" },
  { "]p", desc = "Next Parameter Inner" },
  { "]s", desc = "Next Scope Outer" },

  -- Surround (mini.surround)
  { "s",  group = "Surround" },
  { "sa", desc = "Add Surrounding", mode = { "n", "v" } },
  { "sd", desc = "Delete Surrounding" },
  { "sf", desc = "Find Right" },
  { "sF", desc = "Find Left" },
  { "sh", desc = "Highlight Surrounding" },
  { "sn", desc = "Update n_lines" },
  { "sr", desc = "Replace Surrounding" },

  -- Text objects (operator-pending: use after d/c/v/y)
  -- mini.ai + nvim-various-textobjs + treesitter-textobjects
  { "i", group = "Inner Text Object", mode = "o" },
  { "a", group = "Around Text Object", mode = "o" },
  { "if", desc = "Inner Function", mode = { "o", "x" } },
  { "af", desc = "Around Function", mode = { "o", "x" } },
  { "ic", desc = "Inner Class", mode = { "o", "x" } },
  { "ac", desc = "Around Class", mode = { "o", "x" } },
  { "ib", desc = "Inner Block", mode = { "o", "x" } },
  { "ab", desc = "Around Block", mode = { "o", "x" } },
  { "ia", desc = "Inner Argument", mode = { "o", "x" } },
  { "aa", desc = "Around Argument", mode = { "o", "x" } },
  { "io", desc = "Inner Block/Cond/Loop (mini.ai)", mode = { "o", "x" } },
  { "ao", desc = "Around Block/Cond/Loop (mini.ai)", mode = { "o", "x" } },
  { "iq", desc = "Inner Quote (mini.ai)", mode = { "o", "x" } },
  { "aq", desc = "Around Quote (mini.ai)", mode = { "o", "x" } },
  { "ii", desc = "Inner Indent (various-textobjs)", mode = { "o", "x" } },
  { "ai", desc = "Around Indent (various-textobjs)", mode = { "o", "x" } },
  { "iv", desc = "Inner Value (various-textobjs)", mode = { "o", "x" } },
  { "av", desc = "Around Value (various-textobjs)", mode = { "o", "x" } },
  { "ik", desc = "Inner Key (various-textobjs)", mode = { "o", "x" } },
  { "ak", desc = "Around Key (various-textobjs)", mode = { "o", "x" } },
  { "iS", desc = "Inner Subword (various-textobjs)", mode = { "o", "x" } },
  { "aS", desc = "Around Subword (various-textobjs)", mode = { "o", "x" } },
  { "gG", desc = "Entire Buffer (various-textobjs)", mode = { "o", "x" } },
  { "gc", desc = "Inside Comment (various-textobjs)", mode = { "o", "x" } },

  -- Toggle options (mini.basics)
  { "\\",  group = "Toggle" },
  { "\\b", desc = "Background" },
  { "\\c", desc = "Cursorline" },
  { "\\C", desc = "Cursorcolumn" },
  { "\\d", desc = "Diagnostics" },
  { "\\g", desc = "Git Blame Line", "<cmd>Gitsigns toggle_current_line_blame<cr>" },
  { "\\G", desc = "Git Blame Full", "<cmd>Gitsigns blame<cr>" },
  { "\\h", desc = "Inlay Hints" },
  { "\\i", desc = "Ignorecase" },
  { "\\l", desc = "List" },
  { "\\n", desc = "Number" },
  { "\\r", desc = "Relativenumber" },
  { "\\s", desc = "Spell" },
  { "\\t", desc = "Table Mode", "<cmd>TableModeToggle<cr>" },
  { "\\w", desc = "Wrap" },

  -- Goto prefix
  { "g",   group = "Goto" },
  { "go",  desc = "Add Empty Line Below" },
  { "gO",  desc = "Add Empty Line Above" },

  -- LSP defaults (Neovim 0.11+)
  { "gr",  group = "LSP (builtin)" },
  { "grn", desc = "Rename" },
  { "gra", desc = "Code Action", mode = { "n", "v" } },
  { "grr", desc = "References" },
  { "gri", desc = "Implementation" },

  -- Todo comment navigation
  { "]t", desc = "Next Todo Comment" },
  { "[t", desc = "Previous Todo Comment" },

  -- Misc implicit bindings
  { "K",     desc = "Hover Documentation" },
  { "<C-s>", desc = "Save", mode = { "n", "i", "x" } },
  { "<M-e>", desc = "Autopairs Fast Wrap", mode = "i" },
})
