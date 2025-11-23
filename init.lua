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
-- Easier visual cue for what is copied.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    pattern = "*",
    desc = "highlight selection on yank",
    callback = function()
        vim.highlight.on_yank({ timeout = 200, visual = true })
    end,
})
-- Resize splits
vim.api.nvim_create_autocmd("VimResized", {
    command = "wincmd =",
})

-- enable folding disabled for now.
-- vim: foldmethod=marker foldlevel=0
-- vim.opt.foldmethod = "marker"
-- vim.opt.foldenable = true
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
    -- kanagawa: Theme {{{2
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("kanagawa").setup({
                compile = true,
                colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
                commentStyle = { italic = false },
                keywordStyle = { italic = false },
            })
            vim.cmd([[colorscheme kanagawa]])
        end,
    },
    -- nvim-treesitter: Syntax Highlighting {{{2
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        opts = {},
        config = function()
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
                    "vimdoc",
                    "javascript",
                    "typescript",
                    "html",
                    "css",
                    "json",
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
        end,
    },
    -- render-markdown: Markdown Previews {{{2
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {
            enabled = true,
            completions = { lsp = { enabled = true } },
        },
    },
    -- fzf-lua: Previewing and Grepping {{{2
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
        opts = {
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
            keymap = {
                fzf = {
                    ["ctrl-q"] = "select-all+accept",
                },
                lsp = {
                    ["ctrl-q"] = "select-all+accept",
                },
            },
        },
        keys = {
            -- Files
            {
                mode = "n",
                "<leader>?",
                function()
                    require("fzf-lua").oldfiles()
                end,
                desc = "[?] Find recently opened files",
            },
            {
                mode = "n",
                "<leader><space>",
                function()
                    require("fzf-lua").buffers()
                end,
                desc = "[ ] Find existing buffers",
            },
            {
                mode = "n",
                "<leader>sf",
                function()
                    require("fzf-lua").files()
                end,
                desc = "[S]earch [F]iles",
            },
            {
                mode = "n",
                "<leader>sm",
                function()
                    require("fzf-lua").manpages()
                end,
                desc = "[S]earch [M]anpages",
            },
            -- Grepping
            {
                mode = "n",
                "<leader>/",
                function()
                    require("fzf-lua").lgrep_curbuf()
                end,
                desc = "[/] Live grep current buffer",
            },
            {
                mode = "n",
                "<leader>l",
                function()
                    require("fzf-lua").lines()
                end,
                desc = "[l] Grep open buffer [L]ines",
            },
            {
                mode = "n",
                "<leader>sc",
                function()
                    require("fzf-lua").grep_cword()
                end,
                desc = "[S]earch [C]ursor word",
            },
            {
                mode = "n",
                "<leader>sg",
                function()
                    require("fzf-lua").live_grep()
                end,
                desc = "[S]earch by [G]rep",
            },
            {
                mode = "n",
                "<leader>sl",
                function()
                    require("fzf-lua").live_grep_glob()
                end,
                desc = "[S]earch by grep g[L]ob",
            },
            {
                mode = "n",
                "<leader>sp",
                function()
                    require("fzf-lua").grep_project()
                end,
                desc = "[S]earch [P]roject",
            },
            {
                mode = "n",
                "<leader>sq",
                function()
                    require("fzf-lua").lgrep_quickfix()
                end,
                desc = "[S]earch [Q]uick fix",
            },
            {
                mode = "v",
                "<leader>s",
                function()
                    require("fzf-lua").grep_visual()
                end,
                desc = "[S]earch [V]isual selection",
            },
            -- Git
            {
                mode = "n",
                "<leader>gf",
                function()
                    require("fzf-lua").git_files()
                end,
                desc = "Search [G]it [F]iles",
            },
            {
                mode = "n",
                "<leader>gc",
                function()
                    require("fzf-lua").git_commits()
                end,
                desc = "Search [G]it [C]ommits",
            },
            {
                mode = "n",
                "<leader>gb",
                function()
                    require("fzf-lua").git_bcommits()
                end,
                desc = "Search [G]it [B]uffer commits",
            },
            -- LSP
            {
                mode = "n",
                "<leader>sd",
                function()
                    require("fzf-lua").lsp_document_diagnostics()
                end,
                desc = "[S]earch [D]iagnostics",
            },
            {
                mode = "n",
                "<leader>sw",
                function()
                    require("fzf-lua").lsp_workspace_diagnostics()
                end,
                desc = "[S]earch [W]orkspace diagnostics",
            },
            {
                mode = "n",
                "<leader>so",
                function()
                    require("fzf-lua").lsp_references()
                end,
                desc = "LSP: [S]earch [O]ccurences",
            },
            {
                mode = "n",
                "<leader>ds",
                function()
                    require("fzf-lua").lsp_document_symbols()
                end,
                desc = "LSP: [d]ocument [s]ymbols",
            },
            {
                mode = "n",
                "<leader>ws",
                function()
                    require("fzf-lua").lsp_workspace_symbols()
                end,
                desc = "LSP: [w]orkspace [s]ymbols",
            },
            {
                mode = "n",
                "gI",
                function()
                    require("fzf-lua").lsp_implementations()
                end,
                desc = "LSP: [g]oto [I]mplementation",
            },
            -- Misc
            {
                mode = "n",
                "<leader>sb",
                function()
                    require("fzf-lua").builtin()
                end,
                desc = "[S]earch fzf-lua [B]uiltins",
            },
            {
                mode = "n",
                "<leader>sh",
                function()
                    require("fzf-lua").help_tags()
                end,
                desc = "[S]earch [H]elp",
            },
            {
                mode = "n",
                "<leader>sr",
                function()
                    require("fzf-lua").resume()
                end,
                desc = "[S]earch [R]esume",
            },
        },
    },
    -- mason.nvim: LSP Downloader {{{2
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({})
        end,
    },
    -- gitsigns: Navigate Git {{{2
    {
        "lewis6991/gitsigns.nvim",
        -- Think of gitsigns like themes as gutters are key to UI.
        lazy = false,
        keys = {
            {
                mode = "n",
                "]c",
                function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        require("gitsigns").nav_hunk("next")
                    end
                end,
                desc = "Git: [c] next hunk",
            },
            {
                mode = "n",
                "[c",
                function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        require("gitsigns").nav_hunk("prev")
                    end
                end,
                desc = "Git: [c] prev hunk",
            },
            -- Git Signs Actions
            {
                mode = "n",
                "<leader>hs",
                function()
                    require("gitsigns").stage_hunk()
                end,
                desc = "Git: [h]unk [s]tage",
            },
            {
                mode = "n",
                "<leader>hr",
                function()
                    require("gitsigns").reset_hunk()
                end,
                desc = "Git: [h]unk [r]eset",
            },
            {
                mode = "v",
                "<leader>hs",
                function()
                    require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end,
                desc = "Git: [h]unk [s]tage",
            },
            {
                mode = "v",
                "<leader>hr",
                function()
                    require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end,
                desc = "Git: [h]unk [r]eset",
            },
            {
                mode = "n",
                "<leader>hS",
                function()
                    require("gitsigns").stage_buffer()
                end,
                desc = "Git: [h]unk [S]tage_buffer",
            },
            {
                mode = "n",
                "<leader>hu",
                function()
                    require("gitsigns").undo_stage_hunk()
                end,
                desc = "Git: [h]unk [u]ndo stage hunk",
            },
            {
                mode = "n",
                "<leader>hR",
                function()
                    require("gitsigns").reset_buffer()
                end,
                desc = "Git: [h]unk [R]eset buffer",
            },
            {
                mode = "n",
                "<leader>hp",
                function()
                    require("gitsigns").preview_hunk()
                end,
                desc = "Git: [h]unk [p]review",
            },
            {
                mode = "n",
                "<leader>hb",
                function()
                    require("gitsigns").blame_line({ full = true })
                end,
                desc = "Git: [h]unk [b]lame line",
            },
            {
                mode = "n",
                "<leader>tb",
                function()
                    require("gitsigns").toggle_current_line_blame()
                end,
                desc = "Git: [t]oggle current line [b]lame",
            },
            {
                mode = "n",
                "<leader>hd",
                function()
                    require("gitsigns").diffthis()
                end,
                desc = "Git: [h]unk [d]iff",
            },
            {
                mode = "n",
                "<leader>hD",
                function()
                    require("gitsigns").diffthis("~")
                end,
                desc = "Git: [h]unk [D]iff~",
            },
            {
                mode = "n",
                "<leader>td",
                function()
                    require("gitsigns").toggle_deleted()
                end,
                desc = "Git: [t]oggle [d]eleted",
            },
            -- Text object
            {
                mode = "o",
                "ih",
                function()
                    require("gitsigns").select_hunk()
                end,
                desc = "Git: operate on [i]nternal [h]unk",
            },
            {
                mode = "x",
                "ih",
                function()
                    require("gitsigns").select_hunk()
                end,
                desc = "Git: visual select [i]nternal [h]unk",
            },
        },
        config = function()
            require("gitsigns").setup({})
        end,
    },
    -- which-key.nvim: Which Key? {{{2
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            spec = {
                { "<leader>c", group = "[c]ode" },
                { "<leader>d", group = "[d]ocument" },
                { "<leader>g", group = "[g]it" },
                { "<leader>h", group = "[h]unk git" },
                { "<leader>r", group = "[r]ename" },
                { "<leader>s", group = "[s]earch" },
                { "<leader>w", group = "[w]orkspace" },
            },
        },
    },
    -- lualine.nvim: Bottom Bar {{{2
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "kyazdani42/nvim-web-devicons", opt = true },
        opts = { theme = "kanagawa" },
    },
    -- nvim-autopairs: Pair Completion {{{2
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
        -- use opts = {} for passing setup options
        -- this is equivalent to setup({}) function
    },
    -- oil.nvim: Directories are Buffers {{{2
    {
        "stevearc/oil.nvim",
        ---@module 'oil'
        ---@type oil.SetupOpts
        -- Optional dependencies
        -- dependencies = { { "echasnovski/mini.icons", opts = {} } },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {},
    },
})
-- Neovim LSP {{{1
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
    root_markers = { "build.zig", "build.zig.zon", "zls.json" },
    filetypes = { "zig" },
    settings = {
        zls = {
            -- Whether to enable build-on-save diagnostics
            --
            -- Further information about build-on save:
            -- https://zigtools.org/zls/guides/build-on-save/
            enable_build_on_save = true,

            -- Neovim already provides basic syntax highlighting
            semantic_tokens = "partial",

            -- omit if zig in path
            -- zig_exe_path = ""
        },
    },
}

-- Zig fmt does not believe in any options to be set but comments should be
-- sane and neat throughout a zig file. So comments will get 80 char limit while
-- all code and other text follows zig fmt philosophy.
local function ZigSettings()
    vim.opt_local.colorcolumn = "100"
    vim.opt_local.textwidth = 100 -- wrap at these columns
    vim.opt_local.formatoptions:append("c") -- wrap comments
    vim.opt_local.formatoptions:remove("l") -- allow re-wrapping comments
    vim.opt_local.formatoptions:remove("t") -- don't wrap text/code
end
vim.api.nvim_create_augroup("ZigFileTypeSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = "ZigFileTypeSettings",
    pattern = "zig",
    callback = ZigSettings,
})

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
        -- Note: un-comment the commented out conditional checks if needed but
        -- some language servers like zls don't seem to detect these checks.
        -- Auto-format ("lint") on save.
        -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
        -- if
        --     not client:supports_method("textDocument/willSaveWaitUntil")
        --     and client:supports_method("textDocument/formatting")
        -- then
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
        -- end
        -- End of commented out conditional format on save checks.
        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(args.buf, "Format", function(_)
            vim.lsp.buf.format()
        end, { desc = "Format current buffer with LSP" })
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
