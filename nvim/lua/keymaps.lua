-- Clear search with <ESC>
vim.keymap.set('n', '<Esc>', '<Cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Diagnostics
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil

  return function() go({ severity = severity }) end
end

vim.keymap.set('n', '[d', diagnostic_goto(false), { desc = 'Goto previous diagnostic' })
vim.keymap.set('n', ']d', diagnostic_goto(true), { desc = 'Goto next diagnostic' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Goto previous error' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Goto next error' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Goto previous warning' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Goto next warning' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Move lines - use ALT+J/K to move line up and down
vim.keymap.set('n', '<A-j>', '<Cmd>move+1<CR>==', { noremap = true, desc = 'Move lines down' })
vim.keymap.set('n', '<A-k>', '<Cmd>move-2<CR>==', { noremap = true, desc = 'Move lines up' })
vim.keymap.set('i', '<A-j>', '<Esc><Cmd>move+1<CR>==gi', { noremap = true, desc = 'Move lines down' })
vim.keymap.set('i', '<A-k>', '<Esc><Cmd>move-2<CR>==gi', { noremap = true, desc = 'Move lines up' })
vim.keymap.set('v', '<A-j>', ":move'>+1<CR>gv=gv", { noremap = true, desc = 'Move lines down' })
vim.keymap.set('v', '<A-k>', ":move'<-2<CR>gv=gv", { noremap = true, desc = 'Move lines up' })

-- Split navigation - use <leader>H/J/K/L instead of CTRL+H/J/K/L to navigate window
vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true, desc = 'Go to left window' })
vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true, desc = 'Go to window below' })
vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true, desc = 'Go to window above' })
vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true, desc = 'Go to right window' })

-- Resize window - Use CTRL + arrow keys
vim.keymap.set('n', '<A-Up>', '<Cmd>resize+2<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<A-Down>', '<Cmd>resize-2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<A-Left>', '<Cmd>vertical resize-2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<A-Right>', '<Cmd>vertical resize+2<CR>', { desc = 'Increase window width' })

-- Speed up viewport scrolling
vim.keymap.set('n', '<C-j>', '4<C-e>', { desc = 'Scroll 4 lines down' })
vim.keymap.set('n', '<C-k>', '4<C-y>', { desc = 'Scroll 4 lines up' })

-- Buffers navigation
vim.keymap.set('n', '[b', vim.cmd.bprevious, { noremap = true, desc = 'Previous Buffer' })
vim.keymap.set('n', ']b', vim.cmd.bnext, { noremap = true, desc = 'Next Buffer' })

-- Keep cursor in the middle while in search results
vim.keymap.set('n', 'n', 'nzzzv', { noremap = true, desc = 'Previeous search result' })
vim.keymap.set('n', 'N', 'Nzzzv', { noremap = true, desc = 'Next search result' })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Dedent line' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent line' })

-- Copy to system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', { noremap = true, desc = 'Copy to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<leader>Y', '"+Y', { noremap = true, desc = 'Copy to system clipboard' })

-- Delete word
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d', { noremap = true, desc = 'Delete word' })
