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

-- Completions and LSP

--  This function gets run when an LSP connects to a particular buffer.
--  Currently, things like git integration are though of as part of an
--  LSP because they operate on a project with a well structure git folder.
--  TODO: Consider how this function will work if a nvim/lsp/ folder is
--  idiomatic. How would you get each lsp file to attach this function?
--  For now just initialize all lsp's in this file with on_attach as
--  global function.
local on_attach = function(_, bufnr)
    local gitsigns = require("gitsigns")
    local function map(mode, l, r, desc)
        desc = desc or ""
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
    end
    -- Git Signs setups.
    map("n", "]c", function()
        if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
        else
            gitsigns.nav_hunk("next")
        end
    end)
    map("n", "[c", function()
        if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
        else
            gitsigns.nav_hunk("prev")
        end
    end)
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
    -- See `:help K` for why this key mapping
    map("n", "K", vim.lsp.buf.hover, "hover documentation")
    map("n", "<C-k>", vim.lsp.buf.signature_help, "signature documentation")
    -- Lesser used LSP functionality
    map("n", "gD", vim.lsp.buf.declaration, "LSP: [g]oto [D]eclaration")
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, "LSP: [w]orkspace [a]dd folder")
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, "LSP: [w]orkspace [r]emove folder")
    map("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "LSP: [w]orkspace [l]ist folders")
    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, { desc = "format current buffer with LSP" })
end

require("mason").setup({})

-- Setup lspconfig. Other setups and options could precede these commands.
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

vim.lsp.config["clangd"] = {
    cmd = { "clangd", "--background-index", "--clang-tidy" },
    root_markers = { "compile_commands.json", "compile_flags.txt" },
    filetypes = { "c", "h", "cpp", "hpp", "hx", "hh", "cxx", "cc", "cx" },
    capabilities = capabilities,
    on_attach = on_attach,
}
vim.lsp.enable("clangd")

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
    on_attach = on_attach,
}
vim.lsp.enable("lua-language-server")

vim.lsp.config["marksman"] = {
    cmd = { "marksman" },
    root_markers = { ".editorconfig" },
    filetypes = { "md", "markdown" },
    on_attach = on_attach,
}
vim.lsp.enable("marksman")

vim.lsp.config["rust-analyzer"] = {
    cmd = { "rust-analyzer" },
    root_markers = { "Cargo.toml" },
    filetypes = { "rust", "rs" },
    capabilities = capabilities,
    on_attach = on_attach,
}
vim.lsp.enable("rust-analyzer")

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client:supports_method("textDocument/completion") then
            client.server_capabilities.completionProvider.triggerCharacters =
                vim.split("qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM. ", "")
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
        end
    end,
})

vim.diagnostic.config({
    -- Use the default configuration
    -- virtual_lines = true

    -- Alternatively, customize specific options
    virtual_lines = {
        --  -- Only show virtual line diagnostics for the current cursor line
        current_line = true,
    },
})

require("oil").setup()
