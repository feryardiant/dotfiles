return {

  {
    'lewis6991/gitsigns.nvim',
    dependencies = {
      'vim-fugitive',
    },
    opts = {
      current_line_blame = true,
      signs = {
        untracked = { text = "│" },
      }
    }
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
