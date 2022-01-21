-- Plugins
return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }

  use "projekt0n/github-nvim-theme"

end)
