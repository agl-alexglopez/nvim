require('github-theme').setup({
  theme_style = "light_default",
  comment_style = "NONE",
  keyword_style = "NONE",
  function_style = "NONE",
  variable_style = "NONE",
  sidebars = {"qf", "vista_kind", "terminal", "packer"},

  colors = {hint = "orange", error = "#ff0000"},
  -- Overwrite the highlight groups
  overrides = function(c)
    return {
      htmlTag = {fg = c.red, bg = "#282c34", sp = c.hint, style = "underline"},
      DiagnosticHint = {link = "LspDiagnosticsDefaultHint"},
      -- this will remove the highlight groups
      TSField = {},
    }
  end
})

require('lualine').setup ({
  options = {
    theme = 'auto',
  }
})

require('Comment').setup({
  opleader = {
    -- line comment keymap
    line = 'gc',
    -- block comment keymap
    block = 'gb',
  },
  mappings = {
    -- operator-pending mapping
    -- Includes:
    -- 'gcc'                -> line-comment the current line
    -- 'gcb'                -> block-comment the current line
    -- 'gc[count]{motion}'  -> line-comment the region contained in {motion}.
    -- 'gb[count]{motion}'  -> block-comment the region contained in {motion}.
    basic = true,

    -- extra mapping
    -- Includes
    -- 'gco' -> start new comment line below
    -- 'gcO' -> start new comment line above
    -- 'gcA' -> append comment end of line.
    extra = true,

    -- Pre-hook called before commenting the line is done
    -- Can be used to determine comment string value.
    pre_hook = nil,
    -- Post-hook called after commenting is done
    -- Can be used to alter any formatting / new lines / etc. after commenting
    post_hook = nil,
    -- Can be used to ignore certain lines when doing linewise motions.
    -- Can be string (lua regex)
    -- Or function (that returns lua regex)
    ignore = nil,
  }
})

require'nvim-treesitter.configs'.setup({
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
   ensure_installed = {'python', 'cpp', 'c', 'markdown', 'lua'},

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- List of parsers to ignore installing
  ignore_install = { "javascript" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- list of language that will be disabled
    --disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
})

local npairs = require("nvim-autopairs")

npairs.setup({
  check_ts = true,
  ts_config = {
    lua = {'string'},-- it will not add a pair on that treesitter node
      javascript = {'template_string'},
      java = false,-- don't check treesitter on java
  }
})

-- ---------------------------completions and lsp----------

-- Massively simplified this section. Servers now at least work. Add to as needed.
require("nvim-lsp-installer").setup {}
local lsp_config = require("lspconfig")
-- Setup lspconfig. Other setups and options could precede these commands.
lsp_config.clangd.setup {}
lsp_config.pyright.setup {}
lsp_config.marksman.setup {}

-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  -- Adds nice highlight to first option in the autocomplete menu.
  completion = {completeopt = 'menu,menuone,noinsert'},
  -- Visual border for autocomplete opts.
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({-- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    -- { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
    { name = 'path' },
    { name = 'buffer', keyword_length = 3},
  }),
  experimental = {
    native_menu = false,
    ghost_text = true,
  },

})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer', keyword_length = 3},
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer', keyword_length = 3 },
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline', keyword_length = 3 },
  })
})

-- Luasnip setup

