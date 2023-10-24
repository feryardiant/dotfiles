vim.opt.clipboard = 'unnamedplus'
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.conceallevel = 3
vim.opt.confirm = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.scrolloff = 5

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smartindent = true

vim.opt.list = true
vim.opt.listchars = 'tab:→ ,trail:·,extends:…,precedes:…'
vim.opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = "⸱",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.colorcolumn = '80,100,120'
vim.opt.updatetime = 50

vim.opt.wildmode = 'longest:full,full'
vim.opt.wrap = false

if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.smoothscroll = true
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
end

