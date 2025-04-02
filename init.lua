-- plugins {{{1

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
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Plugins
require("lazy").setup({

    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    { "BurntSushi/ripgrep" },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = [[
        cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build
        ]],
    },

    {
        "nvim-telescope/telescope.nvim",
        --or tag = '0.1.CHOOSE_LATEST_TAG_FROM_REPO'
        branch = "0.1.x",
        dependencies = { { "nvim-lua/plenary.nvim" } },
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
        dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
    },
})

-- setups {{{1

require("tokyonight").setup({
    -- storm, moon, night, day
    style = "moon",
    -- for :terminal
    terminal_colors = true,
    styles = {
        -- Style to be applied to different syntax groups
        -- Value is any valid attr-list value for `:help nvim_set_hl`
        comments = { italic = false },
        keywords = { italic = false },
        -- Background styles. Can be "dark", "transparent" or "normal"
        sidebars = "dark",
        floats = "dark",
    },
    lualine_bold = true,
})

vim.cmd([[colorscheme tokyonight]])

-- The info bar at the bottom of the editor.
require("lualine").setup({
    options = {
        theme = "tokyonight",
    },
})

-- For git editor integration.
require("gitsigns").setup({})

require("telescope").setup({
    defaults = {
        -- Default configuration for telescope goes here:
        -- config_key = value,
        mappings = {
            i = {
                -- map actions.which_key to <C-h> (default: <C-/>)
                -- actions.which_key shows the mappings for your picker,
                -- e.g. git_{create, delete, ...}_branch for the git_branches picker
                ["<C-h>"] = "which_key",
                ["<C-u>"] = false,
                ["<C-d>"] = false,
            },
        },
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
    },
    extensions = {
        fzf = {
            -- false is exact match
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            -- "smart_case", "ignore_case", or "respect_case"
            case_mode = "smart_case",
        },
    },
})

require("telescope").load_extension("fzf")
-- See `:help telescope.builtin`
vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
vim.keymap.set("n", "<leader>/", function()
    -- You can pass additional configuration to telescope to change theme, layout, etc.
    require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
    }))
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
vim.keymap.set("n", "<leader>sf", require("telescope.builtin").find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch by [G]rep" })
vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[S]earch [R]esume" })

require("nvim-treesitter.configs").setup({
    -- One of "all", "maintained" (parsers with maintainers), or a list of languages
    ensure_installed = { "python", "cpp", "c", "markdown", "lua", "rust", "vim" },

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

-- Adds pair completions for brackets, quotes, parens, etc.
require("nvim-autopairs").setup({
    check_ts = true,
    ts_config = {
        -- it will not add a pair on that treesitter node
        lua = { "string" },
        javascript = { "template_string" },
    },
})

require("mason").setup({})

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

vim.lsp.config["marksman"] = {
    cmd = { "marksman" },
    filetypes = { "md", "markdown" },
}

vim.lsp.enable({ "lua-language-server", "clangd", "rust-analyzer", "marksman" })

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
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                end,
            })
            -- Create a command `:Format` local to the LSP buffer
            vim.api.nvim_buf_create_user_command(args.buf, "Format", function(_)
                vim.lsp.buf.format()
            end, { desc = "format current buffer with LSP" })
        end
        -- Buffer and context specific git mappings and actions
        local gitsigns = require("gitsigns")
        local function map(mode, l, r, desc)
            desc = desc or ""
            vim.keymap.set(mode, l, r, { buffer = args.buf, desc = desc })
        end
        map("n", "]c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gitsigns.nav_hunk("next")
            end
        end, "Git: [c] next hunk")
        map("n", "[c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev")
            end
        end, "Git: [c] prev hunk")
        -- Git Signs Actions
        map("n", "<leader>hs", gitsigns.stage_hunk, "Git: [h]unk [s]tage")
        map("n", "<leader>hr", gitsigns.reset_hunk, "Git: [h]unk [r]eset")
        map("v", "<leader>hs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Git: [h]unk [s]tage")
        map("v", "<leader>hr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Git: [h]unk [r]eset")
        map("n", "<leader>hS", gitsigns.stage_buffer, "Git: [h]unk [S]tage_buffer")
        map("n", "<leader>hu", gitsigns.undo_stage_hunk, "Git: [h]unk [u]ndo stage hunk")
        map("n", "<leader>hR", gitsigns.reset_buffer, "Git: [h]unk [R]eset buffer")
        map("n", "<leader>hp", gitsigns.preview_hunk, "Git: [h]unk [p]review")
        map("n", "<leader>hb", function()
            gitsigns.blame_line({ full = true })
        end, "Git: [h]unk [b]lame line")
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, "Git: [t]oggle current line [b]lame")
        map("n", "<leader>hd", gitsigns.diffthis, "Git: [h]unk [d]iff")
        map("n", "<leader>hD", function()
            gitsigns.diffthis("~")
        end, "Git: [h]unk [D]iff~")
        map("n", "<leader>td", gitsigns.toggle_deleted, "Git: [t]oggle [d]eleted")
        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Git select_hunk<CR>")
        -- LSP Actions
        map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: [r]e[n]ame")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: [c]ode [a]ction")
        map("n", "gd", vim.lsp.buf.definition, "LSP: [g]oto [d]efinition")
        map("n", "gr", require("telescope.builtin").lsp_references, "LSP: [g]oto [r]eferences")
        map("n", "gI", require("telescope.builtin").lsp_implementations, "LSP: [g]oto [I]mplementation")
        map("n", "<leader>D", vim.lsp.buf.type_definition, "type [D]efinition")
        map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, "LSP: [d]ocument [s]ymbols")
        map("n", "<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "LSP: [w]orkspace [s]ymbols")
        -- Lesser used LSP functionality
        map("n", "gD", vim.lsp.buf.declaration, "LSP: [g]oto [D]eclaration")
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

-- Open directories as buffers to edit files and folders in nvim.
require("oil").setup()

-- core settings {{{1

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
-- relative numbers can be slower for larger files
--vim.opt.relativenumber = true
-- don't auto commenting new lines n.b. turning off for now to see if I like auto commenting.
--vim.cmd [[au BufEnter * set fo-=c fo-=r fo-=o]]

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

-- Diagnostic keymaps
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
-- enable folding
-- vim: foldmethod=marker foldlevel=0
vim.opt.foldmethod = "marker"
vim.opt.foldenable = true
