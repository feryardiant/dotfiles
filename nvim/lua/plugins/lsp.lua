return {

  {
    'L3MON4D3/LuaSnip',
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
    },
    keys = {
      {
        '<Tab>',
        function()
          return require('luasnip').jumpable(1) and '<Plug>luasnip-jump-next' or '<Tab>'
        end,
        expr = true,
        silent = true,
        mode = 'i',
      },
      { '<Tab>',   function() require('luasnip').jump(1) end,  mode = 's' },
      { '<S-Tab>', function() require('luasnip').jump(-1) end, mode = { 'i', 's' } },
    },
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lsp-signature-help' },
      { 'hrsh7th/cmp-path' },
      { 'onsails/lspkind.nvim' },
    },
    config = function()
      local cmp = require('cmp')
      local cmp_select = { behavior = cmp.SelectBehavior.Insert }

      cmp.setup({
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        }, {
          { name = 'buffer' }
        }),
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, item)
            return require('lspkind').cmp_format({
              mode = 'symbol',
            })(entry, item)
          end
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end
        },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.select_next_item(cmp_select),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(cmp_select),
          ['<C-space>'] = cmp.mapping.complete(),
          ['<Esc>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          })
        })
      })
    end
  },

  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'nvim-cmp' },
    },
    init = function()
      vim.diagnostic.config({
        virtual_text = true
      })
    end,
    config = function(_, opts)
      local lsp_zero = require('lsp-zero')
      local mason_lspconfig = require('mason-lspconfig')

      require('mason').setup({})

      local nmap = function(keys, func, desc)
        if desc then
          desc = 'LSP: ' .. desc
        end
        vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc, remap = false })
      end

      mason_lspconfig.setup({
        ensure_installed = {
          'emmet_ls',
          'jsonls',
          'html',
          'cssls',
          'tailwindcss',
          'svelte',
          -- 'volar',
          'lua_ls',
          'tsserver',
          'eslint',
        },
        handlers = {
          lsp_zero.default_setup,

          function (server_name)
            require('lspconfig')[server_name].setup({})
          end,

          lua_ls = function()
            require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
          end
        }
      })

      lsp_zero.on_attach(function(_, buffer)
        lsp_zero.default_keymaps({ buffer = buffer })

        nmap('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
      end)

      lsp_zero.setup_servers({})
    end
  },

}
