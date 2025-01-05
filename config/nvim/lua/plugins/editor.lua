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
    'ricardoramirezr/blade-nav.nvim',
    dependencies = {
      { 'hrsh7th/nvim-cmp' },
    },
    ft = { 'blade', 'php' },
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = function(_, keys)
      local conform = require('conform')

      return {
        {
          '<leader>fb',
          function() conform.format({ async = true, lsp_fallbak = true, timeout_ms = 5000 }) end,
          desc = '[F]ormat [B]uffer',
        },
        unpack(keys),
      }
    end,
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      log_level = vim.log.levels.WARN,
      formatters = {
        prettier = {
          prepend_args = { '--ignore-unknown' },
        },
      },
      formatters_by_ft = {
        blade = { 'prettier', 'blade-formatter', stop_after_first = true },
        json = { 'prettier', 'jq', stop_after_first = true },
        javascript = { 'prettier', stop_after_first = true },
        lua = { 'stylua' },
        markdown = { 'prettier', 'markdownlint', stop_after_first = true },
        php = { 'pint', stop_after_first = true },
        sql = { 'pg_format', 'sqlfmt', stop_after_first = true },
        yaml = { 'yamlfmt' },
      },
    },
    init = function() vim.o.formatexpr = "v:lua.require('conform').formatexpr()" end,
  },

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
      },
    },
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
    opts = {},
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
    cmd = 'Trouble',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons' },
    },
    keys = {
      { '<leader>xx', '<Cmd>Trouble diagnostics toggle<CR>', desc = '[Trouble] Diagnostics' },
      { '<leader>xX', '<Cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = '[Trouble] Buffer diagnostics' },
      { '<leader>xs', '<Cmd>Trouble symbols toggle focus=false<CR>', desc = '[Trouble] Symbols' },
      {
        '<leader>xl',
        '<Cmd>Trouble lsp toggle focus=false win.position=right<CR>',
        desc = '[Trouble] LSP Definitions',
      },
      { '<leader>xL', '<Cmd>Trouble loclist toggle<CR>', desc = '[Trouble] Location list' },
      { '<leader>xq', '<Cmd>Trouble qflist toggle<CR>', desc = '[Trouble] Quickfix list' },
    },
    opts = {
      use_diagnostic_signs = true,
    },
  },

  {
    'ghostty',
    dir = '/Applications/Ghostty.app/Contents/Resources/vim/vimfiles/',
  },

}
