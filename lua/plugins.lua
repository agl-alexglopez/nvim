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

    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {},
        dependencies = {
            -- If Lazy load -> add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   We use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
    },

    { "BurntSushi/ripgrep" },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
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

    { "L3MON4D3/LuaSnip" },

    { "saadparwaiz1/cmp_luasnip" },

    { "hrsh7th/nvim-cmp" },

    { "hrsh7th/cmp-nvim-lsp-signature-help" },

    { "hrsh7th/cmp-buffer" },

    { "hrsh7th/cmp-path" },

    { "hrsh7th/cmp-nvim-lua" },

    { "hrsh7th/cmp-nvim-lsp" },

    { "hrsh7th/cmp-cmdline" },

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
})
