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
    'folke/trouble.nvim',
    dependencies = {
      { 'nvim-web-devicons' },
    },
    opts = {
      use_diagnostic_signs = true
    }
  }
}
