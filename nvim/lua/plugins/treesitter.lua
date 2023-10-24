return {

  {
    'nvim-treesitter/nvim-treesitter',
    version = false,
    build = ':TSUpdate',
    -- cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    dependencies = {
      { 'nvim-treesitter/playground' },
      -- {
      --   'nvim-treesitter/nvim-treesitter-textobjects',
      -- },
    },
    opts = {
        indent = { enable = true },
        highlight = { enable = true },
        -- https://github.com/windwp/nvim-ts-autotag
        autotag = {
          enable = true,
        },
        -- A list of parser names
        ensure_installed = {
          'html',
          'json',
          'javascript',
          'php',
          'toml',
          'typescript',
          'vim',
          'vimdoc',
          'vue',
          'yaml'
        },
        -- Install parsers asynchronously
        sync_install = false,
        -- Auto install missing parsers when entering buffer
        auto_install = true,
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)
    end
  },

  -- Show context of the current function
  {
    'nvim-treesitter/nvim-treesitter-context',
    enable = true,
    opts = { mode = 'cursor', max_line = 3 }
  },

  -- Automatically add closing tags for HTML and JSX
  {
    'windwp/nvim-ts-autotag',
    opts = {}
  },

}
