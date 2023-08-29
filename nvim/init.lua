local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    is_bootstrap = true
    vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)

    -- Only required if you have packer configured as `opt`
    vim.cmd [[packadd packer.nvim]]
end

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use 'wakatime/vim-wakatime'

    use 'lukas-reineke/indent-blankline.nvim'

    use 'tpope/vim-fugitive'

    use 'lewis6991/gitsigns.nvim'

    use 'nvim-tree/nvim-web-devicons'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.2',
        requires = { 'nvim-lua/plenary.nvim' }
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    use {
        'Shatur/neovim-ayu', as = 'ayu',
        requires = { 'Luxed/ayu-vim' },
    }

    use ('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    use 'nvim-treesitter/playground'

    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
    }

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {'williamboman/mason.nvim'},           -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},     -- Required
            {'hrsh7th/cmp-nvim-lsp'}, -- Required
            {'L3MON4D3/LuaSnip'},     -- Required
        }
    }

    if is_bootstrap then
        require('packer').sync()
    end
end)

if is_bootstrap then
    print '================================================================='
    print ' Plugins are being installed, please ait until Packer completes,'
    print '                      then restart nvim'
    print '================================================================='
    return
end

local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    command = 'source <afile> | PackerCompile',
    group = packer_group,
    pattern = vim.fn.expand '$MYVIMRC'
})

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.wrap = false

vim.opt.list = true
vim.opt.listchars = 'tab:→ ,space:·,trail:·,extends:…,precedes:…'

vim.opt.showmode = false

vim.opt.termguicolors = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.cache/nvim/undo'
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'

vim.opt.colorcolumn = '80,100,120'

vim.opt.updatetime = 50

-- Diagnostics
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Goto previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Goto next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Move lines
vim.keymap.set('n', '<A-j>', "<Cmd>move+1<CR>==", { noremap = true, desc = 'Move lines down' })
vim.keymap.set('n', '<A-k>', "<Cmd>move-2<CR>==", { noremap = true, desc = 'Move lines up' })
vim.keymap.set('i', '<A-j>', "<Esc><Cmd>move+1<CR>==gi", { noremap = true, desc = 'Move lines down' })
vim.keymap.set('i', '<A-k>', "<Esc><Cmd>move-2<CR>==gi", { noremap = true, desc = 'Move lines up' })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { noremap = true, desc = 'Move lines down' })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { noremap = true, desc = 'Move lines up' })

-- Split navigation
vim.keymap.set('t', '<leader>h', '<C-\\><C-n><C-w>h', { noremap = true, desc = 'Go to left window' })
vim.keymap.set('t', '<leader>j', '<C-\\><C-n><C-w>j', { noremap = true, desc = 'Go to window below' })
vim.keymap.set('t', '<leader>k', '<C-\\><C-n><C-w>k', { noremap = true, desc = 'Go to window above' })
vim.keymap.set('t', '<leader>l', '<C-\\><C-n><C-w>l', { noremap = true, desc = 'Go to right window' })
vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true, desc = 'Go to left window' })
vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true, desc = 'Go to window below' })
vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true, desc = 'Go to window above' })
vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true, desc = 'Go to right window' })
vim.keymap.set('i', '<leader>h', '<C-o><C-w>h', { noremap = true, desc = 'Go to left window' })
vim.keymap.set('i', '<leader>j', '<C-o><C-w>j', { noremap = true, desc = 'Go to window below' })
vim.keymap.set('i', '<leader>k', '<C-o><C-w>k', { noremap = true, desc = 'Go to window above' })
vim.keymap.set('i', '<leader>l', '<C-o><C-w>l', { noremap = true, desc = 'Go to right window' })

-- Keep cursor in the middle while in search results
vim.keymap.set('n', 'n', "nzzzv", { noremap = true })
vim.keymap.set('n', 'N', "Nzzzv", { noremap = true })

-- Reserve yanked words
vim.keymap.set('x', '<leader>p', "\"_dP", { noremap = true })

-- Copy to system clipboard
vim.keymap.set({ 'n', 'v' }, '<leader>y', "\"+y", { noremap = true })
vim.keymap.set({ 'n', 'v' }, '<leader>Y', "\"+Y", { noremap = true })

-- actual delete word
vim.keymap.set({ 'n', 'v' }, '<leader>d', "\"_d", { noremap = true })

-- Make behavior more like common editors
vim.keymap.set({ '', 'i' }, '<C-s>', vim.cmd.write, { noremap = true, desc = 'Save' })
vim.keymap.set('i', '<C-z>', '<C-o>u', { noremap = true, desc = 'Undo' })
vim.keymap.set('i', '<S-Left>', '<Esc>vb', { noremap = true, desc = 'Select character left' })
vim.keymap.set('i', '<S-Right>', '<Esc>ve', { noremap = true, desc = 'Select character right' })

-- Tab controls
vim.keymap.set('', '<A-h>', vim.cmd.tabprevious, { noremap = true, desc = 'Previous Tab' })
vim.keymap.set('', '<A-l>', vim.cmd.tabnext, { noremap = true, desc = 'Next Tab' })
vim.keymap.set('', '<A-w>', vim.cmd.tabclose, { noremap = true, desc = 'Close Tab' })
vim.keymap.set({ 'i', 't' }, '<A-w>', '<Esc><Cmd>tabclose<CR>', { noremap = true, desc = 'Close Tab' })
