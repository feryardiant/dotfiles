local builtin = require('telescope.builtin')
local telescope = require('telescope')

vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Find files inside git repository' })
vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, { desc = 'Find [D]ocument [S]ymbols' })
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
-- vim.keymap.set('n', '<leader>ws', builtin.lsp_workspace_symbols, { desc = 'Find [W]orkspace [S]ymbols' })
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

telescope.setup({
    defaults ={
        layout_config = {
            vertical = { width = 0.5 }
        }
    }
})
