----------------------------------------------------------------------
-- terminal-setting Neovim Config
-- VSCode-like editing with Yazi/lazygit integration
-- Based on novim (https://github.com/link2004/novim)
--
-- Features:
--   - Mouse-based operation
--   - Standard shortcuts (Ctrl+S, Ctrl+Z, etc.)
--   - Modeless editing (type to insert)
--   - No vim knowledge required
--   - LSP support (Cmd+Click / F12 for Go to Definition)
--
-- Note: File tree is handled by Yazi, Git by lazygit
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 1. Plugin Manager (lazy.nvim)
----------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Color scheme
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme kanagawa-dragon")
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "|" },
          change       = { text = "|" },
          delete       = { text = "_" },
          topdelete    = { text = "-" },
          changedelete = { text = "~" },
        },
        signs_staged = {
          add          = { text = "|" },
          change       = { text = "|" },
          delete       = { text = "_" },
          topdelete    = { text = "-" },
          changedelete = { text = "~" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        current_line_blame = false,
      })
    end,
  },

  -- Git diff viewer (left: file list, right: diff preview)
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      { "<C-g>", "<cmd>DiffviewOpen<CR>", desc = "Open Git diff view" },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          default = {
            layout = "diff2_horizontal",
          },
        },
        file_panel = {
          listing_style = "tree",
          win_config = {
            position = "left",
            width = 35,
          },
        },
        keymaps = {
          view = {
            ["q"] = "<cmd>DiffviewClose<CR>",
            ["<Esc>"] = "<cmd>DiffviewClose<CR>",
          },
          file_panel = {
            ["q"] = "<cmd>DiffviewClose<CR>",
            ["<Esc>"] = "<cmd>DiffviewClose<CR>",
          },
        },
      })
    end,
  },

  -- Auto formatter (format on save)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          -- JS/TS/JSON/CSS: use LSP (Biome) as primary
          javascript = { lsp_format = "prefer" },
          javascriptreact = { lsp_format = "prefer" },
          typescript = { lsp_format = "prefer" },
          typescriptreact = { lsp_format = "prefer" },
          json = { lsp_format = "prefer" },
          jsonc = { lsp_format = "prefer" },
          css = { lsp_format = "prefer" },
          -- Other languages: use external formatters
          python = { "black" },
          go = { "gofmt" },
          rust = { "rustfmt" },
          lua = { "stylua" },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      })
    end,
  },

}, {
  -- lazy.nvim options
  ui = { border = "rounded" },
})


----------------------------------------------------------------------
-- 2. LSP Configuration (Neovim 0.11+ native)
----------------------------------------------------------------------

-- LSP keymaps (set when any LSP attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf, silent = true }

    -- Go to definition (F12 / gd)
    vim.keymap.set("n", "<F12>", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

    -- Other useful LSP keymaps
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)           -- Show hover info
    vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts)       -- Rename symbol
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)     -- Find references
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
  end,
})

-- TypeScript/JavaScript
vim.lsp.config["ts_ls"] = {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
}

-- Python
vim.lsp.config["pyright"] = {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
}

-- Go
vim.lsp.config["gopls"] = {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.work", ".git" },
}

-- Rust
vim.lsp.config["rust_analyzer"] = {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", ".git" },
}

-- Lua (for Neovim config)
vim.lsp.config["lua_ls"] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
    },
  },
}

-- Biome (formatting + linting for JS/TS/JSON)
vim.lsp.config["biome"] = {
  cmd = { "npx", "biome", "lsp-proxy" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc", "css" },
  root_markers = { "biome.json", "biome.jsonc" },
}

-- Enable all configured LSP servers
vim.lsp.enable({ "ts_ls", "pyright", "gopls", "rust_analyzer", "lua_ls", "biome" })


----------------------------------------------------------------------
-- 3. Display and Input Settings
----------------------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true

-- Fix HMR (Hot Module Replacement) for Next.js/Vite
-- Use overwrite instead of rename to preserve inode
vim.opt.backupcopy = "yes"

-- Hide mode display (INSERT/NORMAL) for VSCode-like feel
vim.opt.showmode = false

-- Always show statusline
vim.opt.laststatus = 2

-- Allow cursor to go one past end of line (for right-edge click)
vim.opt.virtualedit = "onemore"

-- Make Backspace work properly in Insert mode
vim.opt.backspace = { "indent", "eol", "start" }


----------------------------------------------------------------------
-- 4. Mouse Settings
----------------------------------------------------------------------

vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"

-- Share clipboard with OS
vim.opt.clipboard = "unnamedplus"

-- Go to definition function
local function goto_definition()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return
  end

  vim.lsp.buf.definition({
    on_list = function(options)
      if options == nil or options.items == nil or #options.items == 0 then
        return
      end
      local item = options.items[1]
      if item.filename then
        vim.cmd("edit " .. item.filename)
      end
      vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
    end,
  })
end

-- Peek definition in floating window
local function peek_definition()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return
  end

  vim.lsp.buf.definition({
    on_list = function(options)
      if options == nil or options.items == nil or #options.items == 0 then
        return
      end

      local item = options.items[1]
      local filename = item.filename
      local lnum = item.lnum

      -- Read entire file
      local lines = vim.fn.readfile(filename)
      if #lines == 0 then return end

      -- Calculate window size
      local width = math.min(120, math.floor(vim.o.columns * 0.8))
      local height = math.min(30, math.floor(vim.o.lines * 0.6))

      -- Create floating window
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

      -- Set filetype and enable syntax highlighting
      local ext = filename:match("%.([^%.]+)$")
      if ext then
        local ft_map = { ts = "typescript", tsx = "typescriptreact", js = "javascript", jsx = "javascriptreact", py = "python", rs = "rust", go = "go", lua = "lua" }
        local ft = ft_map[ext] or ext
        vim.bo[buf].filetype = ft
        -- Enable syntax highlighting for this buffer
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("syntax enable")
          vim.cmd("filetype detect")
        end)
      end

      local win = vim.api.nvim_open_win(buf, true, {
        relative = "cursor",
        row = 1,
        col = 0,
        width = width,
        height = height,
        style = "minimal",
        border = "rounded",
        title = " " .. vim.fn.fnamemodify(filename, ":t") .. " ",
        title_pos = "center",
      })

      -- Move cursor to definition line
      vim.api.nvim_win_set_cursor(win, { lnum, item.col - 1 })

      -- Highlight definition line
      vim.api.nvim_set_hl(0, "PeekDefinitionLine", { bg = "#3a3a5a" })
      vim.api.nvim_buf_add_highlight(buf, -1, "PeekDefinitionLine", lnum - 1, 0, -1)

      -- Close on Escape or q
      local function close_peek()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end

      vim.keymap.set("n", "<Esc>", close_peek, { buffer = buf, silent = true, nowait = true })
      vim.keymap.set("n", "q", close_peek, { buffer = buf, silent = true, nowait = true })

      -- Enter to jump to definition
      vim.keymap.set("n", "<CR>", function()
        close_peek()
        vim.cmd("edit " .. filename)
        vim.api.nvim_win_set_cursor(0, { lnum, item.col - 1 })
      end, { buffer = buf, silent = true })
    end,
  })
end

-- Ctrl+D: Go to definition (works from any mode)
vim.keymap.set({ "n", "i", "v" }, "<C-d>", function()
  vim.cmd("stopinsert")
  goto_definition()
end, { silent = true })

-- Double-click: Peek definition in floating window
vim.keymap.set({ "n", "i", "v" }, "<2-LeftMouse>", function()
  vim.cmd("stopinsert")
  peek_definition()
end, { silent = true })


----------------------------------------------------------------------
-- 5. Highlight Changed Lines
----------------------------------------------------------------------

-- Highlight color for changed lines
vim.api.nvim_set_hl(0, "ChangedLine", { bg = "#1e3a2a" })

-- Track changed lines and highlight them
local changed_lines = {}
local highlight_ns = vim.api.nvim_create_namespace("changed_lines")

vim.api.nvim_create_autocmd("TextChangedI", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line(".")
    local buf = vim.api.nvim_get_current_buf()
    changed_lines[buf] = changed_lines[buf] or {}
    changed_lines[buf][line] = true

    -- Apply highlight
    vim.api.nvim_buf_add_highlight(buf, highlight_ns, "ChangedLine", line - 1, 0, -1)
  end,
})

-- Clear highlights on save
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_clear_namespace(buf, highlight_ns, 0, -1)
    changed_lines[buf] = {}
  end,
})


----------------------------------------------------------------------
-- 6. Backspace / Delete Support
-- Handle terminal differences (<BS> / <C-h>)
----------------------------------------------------------------------

-- Normal mode: delete one character
vim.keymap.set("n", "<BS>", "X", { silent = true })
vim.keymap.set("n", "<C-h>", "X", { silent = true })

-- Visual mode: delete selection
vim.keymap.set("v", "<BS>", '"_d', { silent = true })
vim.keymap.set("v", "<C-h>", '"_d', { silent = true })
vim.keymap.set("v", "<Del>", '"_d', { silent = true })

-- Visual mode: typing replaces selection (VSCode-like)
-- Printable ASCII characters (32-126) replace selection and enter insert mode
for i = 32, 126 do
  local char = string.char(i)
  -- Skip special keys that need different handling
  if char ~= "\\" then
    vim.keymap.set("v", char, '"_c' .. char, { noremap = true, silent = true })
  end
end
vim.keymap.set("v", "\\", '"_c\\', { noremap = true, silent = true })

-- Enter also replaces selection with newline
vim.keymap.set("v", "<CR>", '"_c<CR>', { noremap = true, silent = true })

-- Normal mode: typing enters insert mode (VSCode-like)
-- Printable ASCII characters (32-126) enter insert mode and type
for i = 32, 126 do
  local char = string.char(i)
  -- Skip ? (used for help) and \ (needs escaping)
  if char ~= "?" and char ~= "\\" then
    vim.keymap.set("n", char, "i" .. char, { noremap = true, silent = true })
  end
end
vim.keymap.set("n", "\\", "i\\", { noremap = true, silent = true })

-- Enter in normal mode starts new line
vim.keymap.set("n", "<CR>", "i<CR>", { noremap = true, silent = true })


----------------------------------------------------------------------
-- 7. Ctrl / Cmd Shortcuts
----------------------------------------------------------------------

-- Select all
vim.keymap.set({ "n", "i", "v" }, "<C-a>", "<Esc>ggVG", { silent = true })
vim.keymap.set({ "n", "i", "v" }, "<D-a>", "<Esc>ggVG", { silent = true })

-- Save (with friendly message)
local function save_file()
  vim.cmd("stopinsert")
  local ok, err = pcall(vim.cmd, "silent write")
  if ok then
    vim.api.nvim_echo({{ "Saved!", "String" }}, false, {})
  else
    vim.api.nvim_echo({{ "Error: " .. err, "ErrorMsg" }}, false, {})
  end
end
vim.keymap.set({ "n", "i", "v" }, "<C-s>", save_file, { silent = true })
vim.keymap.set({ "n", "i", "v" }, "<D-s>", save_file, { silent = true })

-- Undo
vim.keymap.set({ "n", "i", "v" }, "<C-z>", "<Esc>u", { silent = true })
vim.keymap.set({ "n", "i", "v" }, "<D-z>", "<Esc>u", { silent = true })

-- Redo
vim.keymap.set({ "n", "i", "v" }, "<C-S-z>", "<Esc><C-r>", { silent = true })
vim.keymap.set({ "n", "i", "v" }, "<D-S-z>", "<Esc><C-r>", { silent = true })

-- Copy (keep selection after copy)
vim.keymap.set("v", "<C-c>", '"+ygv', { silent = true })
vim.keymap.set("v", "<D-c>", '"+ygv', { silent = true })

-- Paste
vim.keymap.set({ "n", "i", "v" }, "<C-v>", '"+p', { silent = true })
vim.keymap.set({ "n", "i", "v" }, "<D-v>", '"+p', { silent = true })

-- Shift+Arrow: Select text (VSCode-like)
-- From normal mode: start visual selection
vim.keymap.set("n", "<S-Left>", "vh", { silent = true })
vim.keymap.set("n", "<S-Right>", "vl", { silent = true })
vim.keymap.set("n", "<S-Up>", "vk", { silent = true })
vim.keymap.set("n", "<S-Down>", "vj", { silent = true })

-- From insert mode: exit to visual and select
vim.keymap.set("i", "<S-Left>", "<Esc>vh", { silent = true })
vim.keymap.set("i", "<S-Right>", "<Esc>vl", { silent = true })
vim.keymap.set("i", "<S-Up>", "<Esc>vk", { silent = true })
vim.keymap.set("i", "<S-Down>", "<Esc>vj", { silent = true })

-- From visual mode: extend selection
vim.keymap.set("v", "<S-Left>", "h", { silent = true })
vim.keymap.set("v", "<S-Right>", "l", { silent = true })
vim.keymap.set("v", "<S-Up>", "k", { silent = true })
vim.keymap.set("v", "<S-Down>", "j", { silent = true })

-- Search (Ctrl+F)
vim.opt.hlsearch = true    -- Highlight search results
vim.opt.incsearch = true   -- Incremental search
vim.opt.ignorecase = true  -- Case insensitive search
vim.opt.smartcase = true   -- Case sensitive if uppercase present

vim.keymap.set({ "n", "i", "v" }, "<C-f>", "<Esc>/", { silent = true })
vim.keymap.set({ "n", "i", "v" }, "<D-f>", "<Esc>/", { silent = true })

-- Clear search highlight with Esc
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true })


----------------------------------------------------------------------
-- 8. Help Screen (Press ? to show)
----------------------------------------------------------------------

local function show_help()
  local lines = {
    "",
    "        VSCode-like Neovim",
    "",
    "  EDITING",
    "    Click anywhere      Move cursor",
    "    Type                Insert text",
    "    Drag to select      Select text",
    "",
    "  SHORTCUTS",
    "    Ctrl+S              Save",
    "    Ctrl+Z              Undo",
    "    Ctrl+Shift+Z        Redo",
    "    Ctrl+A              Select all",
    "    Ctrl+C              Copy",
    "    Ctrl+V              Paste",
    "",
    "  CODE NAVIGATION (LSP)",
    "    Double-click        Peek definition",
    "    Ctrl+D              Jump to definition",
    "    Enter (in peek)     Jump to file",
    "    Esc (in peek)       Close preview",
    "",
    "  FILE NAVIGATION",
    "    Yazi                File browser",
    "    lazygit             Git operations",
    "    Ctrl+G              Git diff view",
    "",
    "  EXIT",
    "    Esc Esc             Quit",
    "",
    "      Press any key to close...",
    "",
  }

  local width = 46
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- Close on any key (and delete buffer to prevent memory leak)
  local function close_help()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  local close_keys = { "<CR>", "q", "<Esc>", "<Space>", "<BS>", "?" }
  for _, key in ipairs(close_keys) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, "", {
      callback = close_help,
      noremap = true,
      silent = true,
    })
  end
end

-- Press ? to show help
vim.keymap.set("n", "?", show_help, { silent = true })


----------------------------------------------------------------------
-- 9. Dynamic Hints (in statusline)
----------------------------------------------------------------------

-- Generate hints for editor (dynamic based on state)
function _G.get_editor_hints()
  local mode = vim.fn.mode()
  local modified = vim.bo.modified

  if mode == "v" or mode == "V" or mode == "\22" then
    return "^C Copy  ^X Cut  ^A All"
  elseif modified then
    return "^S Save  ^Z Undo"
  else
    return "^V Paste  ^A All"
  end
end

-- Set statusline for editor
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter", "FileType" }, {
  pattern = "*",
  callback = function()
    -- Editor: filename left, editor hints right
    vim.wo.statusline = " %f%m%=%{v:lua.get_editor_hints()} "
  end,
})


----------------------------------------------------------------------
-- 10. Exit
----------------------------------------------------------------------

local function quit_with_confirm()
  -- Check for unsaved buffers
  local unsaved = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      unsaved = true
      break
    end
  end

  -- No unsaved changes, just quit
  if not unsaved then
    vim.cmd("qa")
    return
  end

  -- Show options
  vim.ui.select(
    { "Save and Quit", "Quit without Saving", "Cancel" },
    { prompt = "You have unsaved changes:" },
    function(choice)
      if choice == "Save and Quit" then
        vim.cmd("wa")
        vim.cmd("qa")
      elseif choice == "Quit without Saving" then
        vim.cmd("qa!")
      end
      -- Cancel = do nothing
    end
  )
end

-- Press Esc twice to quit (with confirmation if unsaved)
vim.keymap.set("n", "<Esc><Esc>", quit_with_confirm, { silent = true })


-- Note: Git signs are configured in lazy.nvim plugin section above
