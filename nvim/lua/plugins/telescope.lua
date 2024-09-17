return {

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.4',
    cmd = 'Telescope',
    version = false,
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        enabled = vim.fn.executable('make') == 1,
      },
    },
    opts = function()
      local actions = require('telescope.actions')

      return {
        defaults = {
          path_display = { 'smart' },
          prompt_prefix = ' ',
          selection_caret = ' ',
          layout_config = {
            vertical = { width = 0.5 },
          },
          mappings = {
            i = {
              ['<Esc>'] = actions.close,
            },
            n = {
              ['<Esc>'] = actions.close,
            },
          },
        },
      }
    end,
    init = function()
      local builtin = require('telescope.builtin')

      vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = 'Find files from existing buffer' })
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = 'Find current word' })
      vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Find files inside git repository' })
      vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { desc = 'Find document symbols' })
    end,
    config = function(_, opts)
      local telescope = require('telescope')

      telescope.setup(opts)

      telescope.load_extension('fzf')
      telescope.load_extension('notify')
    end,
  },
}
