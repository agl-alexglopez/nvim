-- Basics
vim.opt.termguicolors = true
vim.opt.encoding = "utf-8"
vim.opt.spelllang = "en_us"
vim.opt.spell = true
-- backspace works on every char in insert mode
vim.opt.backspace = "indent,eol,start"
vim.opt.history = 1000
vim.opt.startofline = true
vim.opt.mouse = "a"
vim.opt.swapfile = false
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.clipboard = "unnamedplus"
-- relative numbers can be slower for larger files
--vim.opt.relativenumber = true
-- don't auto commenting new lines n.b. turning off for now to see if I like auto commenting.
--vim.cmd [[au BufEnter * set fo-=c fo-=r fo-=o]]

-- GUI
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.wrap = true
vim.opt.colorcolumn = "80"

--KeyMap
vim.api.nvim_set_keymap("i", "<C-j>", "<Esc>", {})
vim.api.nvim_set_keymap("t", "<C-j>", "<C-\\><C-N>", {})

-- Ok defaults but try to ensure .editorconfig file in all projects.
vim.opt.autoindent = true
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- remove whitespace on save
--vim.cmd([[au BufWritePre * :%s/\s\+$//e]])

-- Sidebar
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.showcmd = true
vim.opt.modelines = 0

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = "*",
})

-- Terminal for a convenient right split.
-- open a terminal pane on the right using :Term
vim.cmd([[
    command Term :botright vsplit term://$SHELL
]])
-- Terminal visual tweaks
--- enter insert mode when switching to terminal
--- close terminal buffer on process exit
vim.cmd([[
    autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline
    autocmd TermOpen * startinsert
    autocmd BufLeave term://* stopinsert
]])

-- auto formatting
vim.cmd([[
    autocmd BufWritePre <buffer> lua vim.lsp.buf.format()
]])

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- document existing key chains
require("which-key").add({
    { "<leader>c", group = "[C]ode" },
    { "<leader>d", group = "[D]ocument" },
    { "<leader>g", group = "[G]it" },
    { "<leader>h", group = "More git" },
    { "<leader>r", group = "[R]ename" },
    { "<leader>s", group = "[S]earch" },
    { "<leader>w", group = "[W]orkspace" },
})
