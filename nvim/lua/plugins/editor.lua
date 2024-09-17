return {

  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'Bilal2453/luvit-meta', lazy = true },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'tpope/vim-fugitive' },
    },
    opts = {
      current_line_blame = true,
      signs = {
        untracked = { text = '│' },
      }
    }
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module 'ibl'
    ---@type ibl.config
    opts = {},
  },

  {
    'echasnovski/mini.pairs',
    event = { 'BufReadPre', 'BufNewFile' },
    lazy = true,
    opts = {}
  },

  {
    'echasnovski/mini.surround',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {},
  },

  {
    'echasnovski/mini.comment',
    lazy = true,
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },

  {
    'folke/trouble.nvim',
    lazy = true,
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
    opts = {
      use_diagnostic_signs = true
    }
  },

}
