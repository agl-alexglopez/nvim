-- Core Editor Settings {{{1
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
vim.opt.completeopt = "menuone,noinsert,popup,fuzzy"
vim.opt.clipboard = "unnamedplus"
-- GUI
vim.o.winborder = "rounded"
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

-- enable folding
-- vim: foldmethod=marker foldlevel=0
vim.opt.foldmethod = "marker"
vim.opt.foldenable = true
-- Lazy Plugin Management {{{1
-- Install lazy if not installed to prevent plugin errors on new nvim config.
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

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required!
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugins
require("lazy").setup({

    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },

    {
        "ibhagwan/fzf-lua",
        -- optional for icon support
        dependencies = {
            "junegunn/fzf",
            "BurntSushi/ripgrep",
            "nvim-tree/nvim-web-devicons",
            "MeanderingProgrammer/render-markdown.nvim",
        },
        -- or if using mini.icons/mini.nvim
        -- dependencies = { "echasnovski/mini.icons" },
        opts = {},
    },

    { "williamboman/mason.nvim" },

    { "lewis6991/gitsigns.nvim" },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {},
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
    },

    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },

    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        opts = {},
        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
})
-- Plugin Configuration {{{1
-- kanagawa: Theme {{{2
require("kanagawa").setup({
    compile = true,
    theme = "wave",
    commentStyle = { italic = false },
    keywordStyle = { italic = false },
})
vim.cmd([[colorscheme kanagawa]])
-- lualine: Bottom Bar {{{2
require("lualine").setup({
    options = {
        theme = "kanagawa",
    },
})
-- which-key: Which Key? {{{2
require("which-key").add({
    { "<leader>c", group = "[c]ode" },
    { "<leader>d", group = "[d]ocument" },
    { "<leader>g", group = "[g]it" },
    { "<leader>h", group = "[h]unk git" },
    { "<leader>r", group = "[r]ename" },
    { "<leader>s", group = "[s]earch" },
    { "<leader>w", group = "[w]orkspace" },
})
-- oil: Directories are Buffers {{{2
require("oil").setup()
-- fzf-lua: Finding, Grepping, and Previews {{{2
require("fzf-lua").setup({
    winopts = {
        preview = {
            default = "bat",
        },
    },
    -- bat's themes are bad and never match nvim perfectly. Make plain text so
    -- that text is themed according to nvim theme. Keep highlighting, line
    -- numbers, and git diff marks and it looks nice and is not distracting.
    previewers = {
        bat = {
            cmd = "bat",
            args = "--color=never --style=numbers,changes --decorations=always",
        },
    },
})
local fzf_lua = require("fzf-lua")
-- Files
vim.keymap.set("n", "<leader>?", fzf_lua.oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", fzf_lua.buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>sf", fzf_lua.files, { desc = "[S]earch [F]iles" })
-- Grepping
vim.keymap.set("n", "<leader>/", fzf_lua.lgrep_curbuf, { desc = "[/] Live grep current buffer" })
vim.keymap.set("n", "<leader>sw", fzf_lua.grep_cword, { desc = "[S]earch [W]ord under cursor" })
vim.keymap.set("n", "<leader>sg", fzf_lua.live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sl", fzf_lua.live_grep_glob, { desc = "[S]earch by grep g[L]ob" })
vim.keymap.set("n", "<leader>sp", fzf_lua.grep_project, { desc = "[S]earch [P]roject" })
vim.keymap.set("v", "<leader>s", fzf_lua.grep_visual, { desc = "[S]earch [V]isual selection" })
-- Git
vim.keymap.set("n", "<leader>gf", fzf_lua.git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>gc", fzf_lua.git_commits, { desc = "Search [G]it [C]ommits" })
vim.keymap.set("n", "<leader>gb", fzf_lua.git_bcommits, { desc = "Search [G]it [B]uffer commits" })
-- LSP
vim.keymap.set("n", "<leader>sd", fzf_lua.diagnostics_document, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>so", fzf_lua.lsp_references, { desc = "LSP: [S]earch [O]ccurences" })
vim.keymap.set("n", "<leader>ds", fzf_lua.lsp_document_symbols, { desc = "LSP: [d]ocument [s]ymbols" })
vim.keymap.set("n", "<leader>ws", fzf_lua.lsp_workspace_symbols, { desc = "LSP: [w]orkspace [s]ymbols" })
vim.keymap.set("n", "gI", fzf_lua.lsp_implementations, { desc = "LSP: [g]oto [I]mplementation" })
-- Misc
vim.keymap.set("n", "<leader>sb", fzf_lua.builtin, { desc = "[S]earch fzf-lua [B]uiltins" })
vim.keymap.set("n", "<leader>sh", fzf_lua.help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sr", fzf_lua.resume, { desc = "[S]earch [R]esume" })

-- gitsigns: Navigating the Git Gutters {{{2
require("gitsigns").setup({})
local gitsigns = require("gitsigns")
vim.keymap.set("n", "]c", function()
    if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
    else
        gitsigns.nav_hunk("next")
    end
end, { desc = "Git: [c] next hunk" })
vim.keymap.set("n", "[c", function()
    if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
    else
        gitsigns.nav_hunk("prev")
    end
end, { desc = "Git: [c] prev hunk" })
-- Git Signs Actions
vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Git: [h]unk [s]tage" })
vim.keymap.set("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Git: [h]unk [r]eset" })
vim.keymap.set("v", "<leader>hs", function()
    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Git: [h]unk [s]tage" })
vim.keymap.set("v", "<leader>hr", function()
    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
end, { desc = "Git: [h]unk [r]eset" })
vim.keymap.set("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Git: [h]unk [S]tage_buffer" })
vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "Git: [h]unk [u]ndo stage hunk" })
vim.keymap.set("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Git: [h]unk [R]eset buffer" })
vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Git: [h]unk [p]review" })
vim.keymap.set("n", "<leader>hb", function()
    gitsigns.blame_line({ full = true })
end, { desc = "Git: [h]unk [b]lame line" })
vim.keymap.set("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Git: [t]oggle current line [b]lame" })
vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, { desc = "Git: [h]unk [d]iff" })
vim.keymap.set("n", "<leader>hD", function()
    gitsigns.diffthis("~")
end, { desc = "Git: [h]unk [D]iff~" })
vim.keymap.set("n", "<leader>td", gitsigns.toggle_deleted, { desc = "Git: [t]oggle [d]eleted" })
-- Text object
vim.keymap.set("o", "ih", gitsigns.select_hunk, { desc = "Git: operate on [i]nternal [h]unk" })
vim.keymap.set("x", "ih", gitsigns.select_hunk, { desc = "Git: visual select [i]nternal [h]unk" })

-- nvim-treesitter: Syntax Highlighting {{{2
require("nvim-treesitter.configs").setup({
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = {
        "python",
        "cpp",
        "c",
        "markdown",
        "markdown_inline",
        "lua",
        "rust",
        "vim",
    },

    -- Install languages synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- List of parsers to ignore installing
    --ignore_install = { "javascript" },

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- list of language that will be disabled
        -- disable = { "" },

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
})
-- nvim-autopairs: Autocomplete Symbol Pairs {{{2
require("nvim-autopairs").setup({
    check_ts = true,
    ts_config = {
        -- it will not add a pair on that treesitter node
        lua = { "string" },
        javascript = { "template_string" },
    },
})
-- mason: Manage LSP Servers via Neovim {{{2
require("mason").setup({})
-- vim.[lsp|api|diagnostic]: Native LSP Configuration {{{2
vim.filetype.add({
    extension = {
        cpp = "cpp",
        cxx = "cpp",
        cx = "cpp",
        cc = "cpp",
        hpp = "cpp",
        hh = "cpp",
        hx = "cpp",
        c = "c",
        h = "c",
    },
})

vim.lsp.config("*", {
    root_markers = { ".git" },
    capabilities = {
        textDocument = {
            semanticTokens = {
                multilineTokenSupport = true,
            },
        },
    },
})

vim.lsp.config["lua-language-server"] = {
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json" },
    filetypes = { "lua" },
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim", "capabilities" },
            },
        },
    },
}

vim.lsp.config["clangd"] = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    root_markers = { ".clangd", "compile_commands.json", "compile_flags.txt" },
    filetypes = { "c", "h", "cpp", "hpp", "hx", "hh", "cxx", "cc", "cx" },
}

vim.lsp.config["rust-analyzer"] = {
    cmd = { "rust-analyzer" },
    root_markers = { "Cargo.toml" },
    filetypes = { "rust", "rs" },
}

vim.lsp.config["zls"] = {
    cmd = { "zls" },
    root_markers = { "build.zig", "build.zig.zon" },
    filetypes = { "zig" },
}

vim.lsp.config["marksman"] = {
    cmd = { "marksman" },
    filetypes = { "md", "markdown" },
}

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "h", "cpp", "hpp", "hx", "hh", "cxx", "cc", "cx", "lua" },
    callback = function()
        vim.opt_local.colorcolumn = "80"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "rust", "rs" },
    callback = function()
        vim.opt_local.colorcolumn = "100"
    end,
})

vim.lsp.enable({
    "lua-language-server",
    "clangd",
    "rust-analyzer",
    "zls",
    "marksman",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method("textDocument/completion") then
            client.server_capabilities.completionProvider.triggerCharacters =
                vim.split("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM.> ", "")
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
        -- Auto-format ("lint") on save.
        -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
        if
            not client:supports_method("textDocument/willSaveWaitUntil")
            and client:supports_method("textDocument/formatting")
        then
            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({
                        bufnr = args.buf,
                        id = client.id,
                        timeout_ms = 1000,
                    })
                end,
            })
            -- Create a command `:Format` local to the LSP buffer
            vim.api.nvim_buf_create_user_command(args.buf, "Format", function(_)
                vim.lsp.buf.format()
            end, { desc = "format current buffer with LSP" })
        end
        local function map(mode, l, r, desc)
            desc = desc or ""
            vim.keymap.set(mode, l, r, { buffer = args.buf, desc = desc })
        end
        -- LSP Actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: [r]e[n]ame")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: [c]ode [a]ction")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "type buffer [D]efinition")
        map("n", "gd", vim.lsp.buf.definition, "LSP: [g]oto buffer [d]efinition")
        map("n", "gD", vim.lsp.buf.declaration, "LSP: [g]oto [D]eclaration")
        -- Lesser used LSP functionality
        map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: [w]orkspace [a]dd folder")
        map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: [w]orkspace [r]emove folder")
        map("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, "LSP: [w]orkspace [l]ist folders")
    end,
})

-- A little function to switch how to show diagnostics
local default_config = { virtual_lines = { current_line = true } }
vim.diagnostic.config(default_config)

vim.keymap.set("n", "<leader>e", function()
    -- virtual_lines is either a table or true/false, let's just check for the
    -- boolean value.
    if vim.diagnostic.config().virtual_lines == true then
        vim.diagnostic.config(default_config)
    else
        vim.diagnostic.config({ virtual_lines = true })
    end
end, { desc = "[e] toggle all errors or current line errors" })
-- Diagnostic keymap
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })
-- render-markdown: Render Markdown in Previews {{{2
require("render-markdown").setup({
    enabled = true,
    completions = { lsp = { enabled = true } },
})
