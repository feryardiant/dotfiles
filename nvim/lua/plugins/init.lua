return {

  {
    'Shatur/neovim-ayu', name = 'ayu',
    lazy = false,
    priority = 1000,
    init = function ()
      vim.cmd.colorscheme('ayu')
    end,
    config = function ()
      local colors = require('ayu.colors')
      local ayu = require('ayu')

      colors.generate(true)

      ayu.setup({
        overrides = {
          Normal = { bg = 'none' },
          -- NormalFloat = { bg = '#3a3a3a' },
          SignColumn = { fg = colors.comment },
          LineNr = { fg = colors.comment },
          Comment = { fg = colors.comment },
          -- CursorLine = { bg = '#1c1c1c' },
          -- CursorLineNr = { fg = colors.accent },
          -- ColorColumn = { bg = '#262626' },
          -- Pmenu = { bg = colors.selection_inactive },
          -- PmenuSel = { bg = colors.selection_bg },
          -- Visual = { bg = colors.selection_bg },
        }
      })
    end
  },

  {
    'wakatime/vim-wakatime',
    lazy = false,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {},
  },

  {
    'rcarriga/nvim-notify',
    config = function ()
      local notify = require('notify')

      ---@diagnostic disable: missing-fields
      notify.setup({
        minimum_width = 25,
        max_width = 50,
        background_colour = '#000000',
      })
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function ()
      require('noice').setup({
        lsp = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = false,
        },
        messages = {
          view = 'mini'
        },
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          -- inc_rename = false, -- enables an input dialog for inc-rename.nvim
          -- lsp_doc_border = f, -- add a border to hover docs and signature help
        },
      })
    end
  },

  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    -- dependencies = {
    --   { 'Bilal2453/luvit-meta', lazy = true },
    -- },
    opts = {
      -- library = {
      --   -- Load luvit types when the `vim.uv` word is found
      --   { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      -- },
    },
  },

  {
    'tpope/vim-fugitive',
  },

  {
    'nvim-lua/plenary.nvim',
  },

  {
    'nvim-tree/nvim-web-devicons'
  },
}
