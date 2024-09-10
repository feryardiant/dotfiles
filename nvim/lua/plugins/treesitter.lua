return {

  {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    build = ':TSUpdate',
    -- cmd = { 'TSUpdateSync', 'TSUpdate', 'TSInstall' },
    dependencies = {
      { 'nvim-treesitter/playground' },
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      {
        'JoosepAlviste/nvim-ts-context-commentstring',
        opts = {
          enable_autocmd = false,
        },
      },

      -- Show context of the current function
      {
        'nvim-treesitter/nvim-treesitter-context',
        enabled = true,
        opts = { mode = 'cursor', max_line = 3 }
      },

      -- Automatically add closing tags for HTML and JSX
      { 'windwp/nvim-ts-autotag' },
    },
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      -- A list of parser names
      ensure_installed = {
        'bash',
        'gitignore',
        'html',
        'json',
        'javascript',
        'markdown',
        'markdown_inline',
        'php',
        'toml',
        'typescript',
        'tsx',
        'vim',
        'vimdoc',
        'vue',
        'yaml'
      },
      -- Install parsers asynchronously
      sync_install = false,
      -- Auto install missing parsers when entering buffer
      auto_install = true,
      -- Incremental selection
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<C-space>',
          node_incremental = '<C-space>',
          node_decremental = '<bs>',
        },
      }
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end
  },

}
