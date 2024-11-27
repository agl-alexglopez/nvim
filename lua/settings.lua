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
    autocmd TermOpen * setlocal listchars= nonumber norelativenumber nocursorline nospell
    autocmd TermOpen * startinsert
    autocmd BufLeave term://* stopinsert
]])

-- auto formatting
-- START COPYPASTA https://github.com/neovim/neovim/commit/5b04e46d23b65413d934d812d61d8720b815eb1c
local util = require("vim.lsp.util")
--- Formats a buffer using the attached (and optionally filtered) language
--- server clients.
---
--- @param options table|nil Optional table which holds the following optional fields:
---     - formatting_options (table|nil):
---         Can be used to specify FormattingOptions. Some unspecified options will be
---         automatically derived from the current Neovim options.
---         @see https://microsoft.github.io/language-server-protocol/specification#textDocument_formatting
---     - timeout_ms (integer|nil, default 1000):
---         Time in milliseconds to block for formatting requests. Formatting requests are current
---         synchronous to prevent editing of the buffer.
---     - bufnr (number|nil):
---         Restrict formatting to the clients attached to the given buffer, defaults to the current
---         buffer (0).
---     - filter (function|nil):
---         Predicate to filter clients used for formatting. Receives the list of clients attached
---         to bufnr as the argument and must return the list of clients on which to request
---         formatting. Example:
---
---         <pre>
---         -- Never request typescript-language-server for formatting
---         vim.lsp.buf.format {
---           filter = function(clients)
---             return vim.tbl_filter(
---               function(client) return client.name ~= "tsserver" end,
---               clients
---             )
---           end
---         }
---         </pre>
---
---     - id (number|nil):
---         Restrict formatting to the client with ID (client.id) matching this field.
---     - name (string|nil):
---         Restrict formatting to the client with name (client.name) matching this field.
vim.lsp.buf.format = function(options)
    options = options or {}
    local bufnr = options.bufnr or vim.api.nvim_get_current_buf()
    local clients = vim.lsp.buf_get_clients(bufnr)

    if options.filter then
        clients = options.filter(clients)
    elseif options.id then
        clients = vim.tbl_filter(function(client)
            return client.id == options.id
        end, clients)
    elseif options.name then
        clients = vim.tbl_filter(function(client)
            return client.name == options.name
        end, clients)
    end

    clients = vim.tbl_filter(function(client)
        return client.supports_method("textDocument/formatting")
    end, clients)

    if #clients == 0 then
        vim.notify("[LSP] Format request failed, no matching language servers.")
    end

    local timeout_ms = options.timeout_ms or 1000
    for _, client in pairs(clients) do
        local params = util.make_formatting_params(options.formatting_options)
        local result, err = client.request_sync("textDocument/formatting", params, timeout_ms, bufnr)
        if result and result.result then
            util.apply_text_edits(result.result, bufnr, client.offset_encoding)
        elseif err then
            vim.notify(string.format("[LSP][%s] %s", client.name, err), vim.log.levels.WARN)
        end
    end
end
-- END COPYPASTA

vim.api.nvim_create_augroup("LspFormatting", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    group = "LspFormatting",
    callback = function()
        vim.lsp.buf.format({
            timeout_ms = 2000,
            filter = function(clients)
                return vim.tbl_filter(function(client)
                    return pcall(function(_client)
                        return _client.config.settings.autoFixOnSave or false
                    end, client) or false
                end, clients)
            end,
        })
    end,
})

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- document existing key chains
require("which-key").add({
    { "<leader>c", group = "[c]ode" },
    { "<leader>d", group = "[d]ocument" },
    { "<leader>g", group = "[g]it" },
    { "<leader>h", group = "[h]unk git" },
    { "<leader>r", group = "[r]ename" },
    { "<leader>s", group = "[s]earch" },
    { "<leader>w", group = "[w]orkspace" },
})
