return {

  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function ()
      local lint = require('lint')

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        php = { 'pint' },
        javascript = { 'eslint' },
        typescript = { 'eslint' },
        javascriptreact = { 'eslint' },
        typescriptreact = { 'eslint' },
        svlete = { 'eslint' },
        vue = { 'eslint' },
      }

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint', { clear = true }),
        callback = function ()
          lint.try_lint()
        end
      })

      vim.keymap.set('n', '<leader>l', function ()
        lint.try_lint()
      end, { desc = 'Trigger linting for current file' })
    end
  },

}
