return {

  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require('lint')

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        javascript = { 'eslint_d' },
        typescript = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
        svlete = { 'eslint_d' },
        vue = { 'eslint_d' },
      }

      lint.linters.eslint_d = require('lint.util').wrap(lint.linters.eslint_d, function (diagnostic)
        if diagnostic.message:find('Error: Could not find config file') then
          return nil
        end

        return diagnostic
      end)

      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('lint', { clear = true }),
        callback = function() lint.try_lint() end,
      })

      vim.keymap.set('n', '<leader>l', function() lint.try_lint() end, { desc = 'Trigger linting for current file' })
    end,
  },
}
