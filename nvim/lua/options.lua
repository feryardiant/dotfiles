vim.opt.termguicolors = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.conceallevel = 3

vim.opt.confirm = true -- Confirm before exit if file has changed
vim.opt.hidden = false -- Close the buffer when tab is closed
vim.opt.wrap = false -- Do not wrap lines

vim.opt.fileformats = 'unix,dos,mac' -- Use Unix as the standard file type
vim.opt.colorcolumn = '80,100,120'

vim.opt.formatoptions = {
  c = true, -- Format comments
  r = true, -- Continue comments by default
  o = true, -- Make comment when using o or O from comment line
  q = true, -- Format comments with gq
  n = true, -- Recognize numbered lists
  l = true, -- Don't break lines that are already long
}

vim.opt.number = true -- Enable line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.cursorline = true -- Highlight line under the cursor

-- vim.opt.signcolumn = 'yes'

-- Persistent Undo
vim.opt.undofile = true
vim.opt.undolevels = 10000

vim.opt.report = 0 -- Show all command reports
vim.opt.ruler = true -- Show cursor position
vim.opt.showmode = false -- Hide the current mode
vim.opt.updatetime = 50

-- Completion
vim.opt.wildmode = 'longest:full,full'
vim.opt.showfulltag = true
vim.opt.completeopt = 'menu,menuone,noselect'

-- Scrolling
vim.opt.scrolloff = 5 -- Start scrolling three lines before horizontal border of window
vim.opt.sidescrolloff = 5 -- Start scrolling three columns before vertical border of window

if vim.fn.has('nvim-0.10') == 1 then vim.opt.smoothscroll = true end

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Auto/Smart/Copy indent from last line when starting new line
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.copyindent = true

-- Search
vim.opt.hlsearch = true -- Highlight searches
vim.opt.incsearch = true -- Highlight dynamically as pattern is typed
vim.opt.ignorecase = true -- Ignore case of searches
vim.opt.smartcase = true -- Ignore 'ignorecase' if search patter contains uppercase characters
vim.opt.wrapscan = true -- Searches wrap around end of file

-- Window splitting
vim.opt.splitbelow = true -- New window goes below
vim.opt.splitright = true -- New windows goes right

-- Folding
vim.opt.foldenable = false
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- Whitespace characters
vim.opt.list = true
vim.opt.listchars = 'tab:→ ,trail:·,extends:…,precedes:…'
vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = '⸱',
  -- fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

vim.opt.suffixes =
  '.bak,~,.cache,.swp,.swo,.o,.d,.info,.aux,.dvi,.bin,.cb,.dmg,.exe,.ind,.idx,.inx,.out,.toc,.pyc,.pyd,.dll'
vim.opt.wildignore = {
  '*.jpg',
  '*.jpeg',
  '*.gif',
  '*.png',
  '*.gif',
  '*.psd',
  '*.pdf',
  '*.o',
  '*.obj',
  '*.min.js',
  '*/smarty/*',
  '*/vendor/*',
  '*/node_modules/*',
  '*/.git/*',
  '*/.sass-cache/*',
}

vim.filetype.add({
  extension = {
    keymap = 'dst',
    neon = 'yaml',
    overlay = 'dst',
  },
  pattern = {
    ['.*%.blade%.php'] = 'blade',
    ['.*%.neon%.dist'] = 'yaml',
  },
})
