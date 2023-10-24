return {

  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      { 'nvim-treesitter/playground' },
      { 'windwp/nvim-ts-autotag' },
      { 'nvim-treesitter/nvim-treesitter-context', opts = { enable = true } }
    },
    config = function()
      require('nvim-treesitter.configs').setup({
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

        indent = { enable = true },
        highlight = { enable = true }
      })
    end
  },

}
