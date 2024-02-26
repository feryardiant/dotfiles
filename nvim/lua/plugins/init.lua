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

      colors.generate()

      ayu.setup({
        overrides = {
          -- Normal = { bg = 'none' },
          -- NormalFloat = { bg = '#3a3a3a' },
          -- SignColumn = { fg = colors.comment },
          -- LineNr = { fg = colors.comment },
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
    'tpope/vim-fugitive',
  },

  {
    'nvim-tree/nvim-web-devicons'
  },
}
