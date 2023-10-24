return {
  {
    'tpope/vim-dotenv'
  },

  {
    'tpope/vim-fugitive',
  },

  {
    'nvim-tree/nvim-web-devicons'
  },

  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'vim-fugitive',
    },
    opts = {}
  },

  {
    'm4xshen/autoclose.nvim',
    opts = {}
  },

  {
    'numToStr/Comment.nvim',
    lazy = false,
    opts = {},
  },

  {
    'nvim-telescope/telescope.nvim', tag = '0.1.4',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
    opts = {}
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function ()
      require('lualine').setup({
        options = {
          componnet_separators = '',
          section_separators = '',
        },
      })
    end
  }
}
