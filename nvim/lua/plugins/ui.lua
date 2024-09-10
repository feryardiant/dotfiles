return {

  {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
  },

  -- {
  --   'akinsho/bufferline.nvim',
  --   opts = {
  --     options = {
  --       mode = 'tabs',
  --       diagnostics = 'nvim_lsp',
  --       offsets = {
  --         {
  --           filetype = 'neo-tree',
  --           text = 'File Explorer',
  --           highlight = 'Directory',
  --         }
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     require('bufferline').setup(opts)
  --   end
  -- },

  {
    'nvim-lualine/lualine.nvim',
    opts = function()
      vim.o.laststatus = vim.g.lualine_laststatus

      return {
        options = {
          theme = 'auto',
          globalstatus = true,
          disabled_filetypes = { 'dashboard', 'alpha', 'starter' },
          componnet_separators = '',
          section_separators = '',
        },
        extensions = { 'neo-tree', 'lazy' },
      }
    end,
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        vim.o.statusline = ''
      else
        vim.o.laststatus = 0
      end
    end,
    config = function (_, opts)
      require('lualine').setup(opts)
    end
  },

}
