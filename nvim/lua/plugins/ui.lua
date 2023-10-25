return {

  {
    'akinsho/bufferline.nvim',
    opts = {
      options = {
        mode = 'tabs',
        diagnostics = 'nvim_lsp',
        offsets = {
          {
            filetype = 'neo-tree',
            text = 'File Explorer',
            highlight = 'Directory',
          }
        },
      },
    },
    config = function(_, opts)
      require('bufferline').setup(opts)
    end
  }

}
