vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('bootstrap')

require('lazy').setup({
  spec = { import = 'plugins' },
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wrap = false

vim.opt.list = true
vim.opt.listchars = 'tab:→ ,trail:·,extends:…,precedes:…'

vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.colorcolumn = '80,100,120'
vim.opt.updatetime = 50

vim.opt.hlsearch = true
vim.opt.incsearch = true
