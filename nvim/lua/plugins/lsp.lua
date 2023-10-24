return {
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-path' },
      { 'L3MON4D3/LuaSnip' },
    },
    config = function ()
      local lsp_zero = require('lsp-zero')
      local cmp = require('cmp')

      cmp.setup({
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'nvim_lsp_signature_help' },
        }),
        formatting = lsp_zero.cmp_format(),
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end
        },
      })
    end
  },

  {
    'williamboman/mason.nvim',
    dependencies = {
      { 'williamboman/mason-lspconfig.nvim' },
    },
    config = function ()
      local lsp_zero = require('lsp-zero')

      require('mason').setup({})
      require('mason-lspconfig').setup({
        ensure_installed = {'jsonls', 'lua_ls', 'tsserver'},
        handlers = {
          lsp_zero.default_setup,
          lua_ls = function()
            require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
          end
        }
      })
    end
  },

  {
    'VonHeikemen/lsp-zero.nvim', branch = 'v3.x',
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'mason.nvim' },
      { 'onsails/lspkind.nvim' },
      { 'nvim-cmp' },
    },
    config = function ()
      local lsp_zero = require('lsp-zero')

      lsp_zero.on_attach(function(_, buffer)
        lsp_zero.default_keymaps({ buffer = buffer })

        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end
          vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc, remap = false })
        end

        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
      end)

      lsp_zero.setup_servers({})

      vim.diagnostic.config({
        virtual_text = true
      })
    end
  },

}
