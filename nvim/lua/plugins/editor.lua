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
    'echasnovski/mini.pairs',
    opts = {}
  },

  {
    'echasnovski/mini.comment',
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      enable_autocmd = false,
    },
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
