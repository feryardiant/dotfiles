vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
    sort_by = 'case_sensitive',
    -- filters = {
    --     dotfiles = true
    -- }
})

vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>')
