require('github-theme').setup({
  theme_style = "dark_default",
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
require('nvim-web-devicons').setup()
require('lualine').setup ({
  options = {
    theme = 'github',
  }
})
