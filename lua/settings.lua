-- Basics
vim.opt.encoding = "utf-8"
vim.opt.backspace = "indent,eol,start" -- backspace works on every char in insert mode
vim.opt.history = 1000
vim.opt.startofline = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.swapfile = false
vim.opt.completeopt = 'menuone,noselect'
-- don't auto commenting new lines
vim.cmd [[au BufEnter * set fo-=c fo-=r fo-=o]]

-- GUI
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.wrap = true
vim.opt.colorcolumn = '100'

--KeyMap
vim.api.nvim_set_keymap('i', 'fd', '<esc>', {})

-- Tabs Spaces White Char
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- remove whitespace on save
vim.cmd[[au BufWritePre * :%s/\s\+$//e]]
-- 2 spaces for select filetypes
vim.cmd [[
  autocmd FileType xml,html,xhtml,css,scss,javascript,lua,yaml setlocal shiftwidth=2 tabstop=2
]]

-- Sidebar
vim.opt.number = true
vim.opt.numberwidth = 3
vim.opt.showcmd = true
vim.opt.modelines = 0

-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Terminal
-- open a terminal pane on the right using :Term
vim.cmd [[command Term :botright vsplit term://$SHELL]]
-- Terminal visual tweaks
--- enter insert mode when switching to terminal
--- close terminal buffer on process exit
vim.cmd [[
    autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline
    autocmd TermOpen * startinsert
    autocmd BufLeave term://* stopinsert
]]

-- Theme
vim.opt.termguicolors = true
