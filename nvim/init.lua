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
--
-- Note: File tree is handled by Yazi, Git by lazygit
----------------------------------------------------------------------


----------------------------------------------------------------------
-- 1. Kanagawa Dragon Color Scheme (matches Ghostty theme)
----------------------------------------------------------------------

-- Load kanagawa with dragon variant
vim.cmd("colorscheme kanagawa-dragon")


----------------------------------------------------------------------
-- 2. Display and Input Settings
----------------------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true

-- Hide mode display (INSERT/NORMAL) for VSCode-like feel
vim.opt.showmode = false

-- Always show statusline
vim.opt.laststatus = 2

-- Allow cursor to go one past end of line (for right-edge click)
vim.opt.virtualedit = "onemore"

-- Make Backspace work properly in Insert mode
vim.opt.backspace = { "indent", "eol", "start" }


----------------------------------------------------------------------
-- 3. Mouse Settings
----------------------------------------------------------------------

vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"

-- Share clipboard with OS
vim.opt.clipboard = "unnamedplus"


----------------------------------------------------------------------
-- 4. Highlight Changed Lines
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
-- 5. Backspace / Delete Support
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
-- 6. Ctrl / Cmd Shortcuts
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


----------------------------------------------------------------------
-- 7. Help Screen (Press ? to show)
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
    "  NAVIGATION",
    "    Yazi                File browser",
    "    lazygit             Git operations",
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
-- 8. Dynamic Hints (in statusline)
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
-- 9. Exit
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


----------------------------------------------------------------------
-- 10. Git Signs (show changed lines)
----------------------------------------------------------------------

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
  current_line_blame = false,  -- Set to true to show git blame inline
})
