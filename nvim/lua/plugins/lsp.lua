return {

  -- {
  --   'L3MON4D3/LuaSnip',
  --   opts = {
  --     history = true,
  --     delete_check_events = 'TextChanged',
  --   },
  --   keys = {
  --     {
  --       '<Tab>',
  --       function()
  --         return require('luasnip').jumpable(1) and '<Plug>luasnip-jump-next' or '<Tab>'
  --       end,
  --       expr = true,
  --       silent = true,
  --       mode = 'i',
  --     },
  --     { '<Tab>',   function() require('luasnip').jump(1) end,  mode = 's' },
  --     { '<S-Tab>', function() require('luasnip').jump(-1) end, mode = { 'i', 's' } },
  --   },
  -- },

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
          -- { name = 'luasnip' },
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
        -- snippet = {
        --   expand = function(args)
        --     require('luasnip').lsp_expand(args.body)
        --   end
        -- },
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
          'lua_ls',
          'eslint',
          'volar',
        },
        handlers = {
          -- lsp_zero.default_setup,

          function (server_name)
            require('lspconfig')[server_name].setup({})
          end,

          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#volar
          volar = function()
            local util = require('lspconfig.util')
            local global_lib = '/opt/homebrew/lib/node_modules/typescript/lib'

            local function get_ts_server_path(root_dir)
              local found_lib = ''
              local function check_dir(path)
                found_lib = util.path.join(path, 'node_modules', 'typescript', 'lib')
                if util.path.exists(found_lib) then
                  return path
                end
              end

              if util.search_ancestors(root_dir, check_dir) then
                return found_lib
              else
                return global_lib
              end
            end

            require('lspconfig').volar.setup({
              filetypes = { 'vue', 'typescript', 'javascript' },
              init_options = {
                tsdk = '/opt/homebrew/lib/node_modules/typescript/lib'
              },
              on_new_config = function(new_config, new_root_dir)
                new_config.init_options.typescript.tsdk = get_ts_server_path(new_root_dir)
              end,
            })
          end,

          tsserver = function()
            local lspconfig = require('lspconfig')
            local vue_typescript_plugin = require('mason-registry')
              .get_package('vue-language-server')
              :get_install_path()
              .. '/node_modules/@vue/language-server'
              .. '/node_modules/@vue/typescript-plugin'

            lspconfig.ts_ls.setup({
              init_options = {
                plugins = {
                  {
                    name = "@vue/typescript-plugin",
                    location = vue_typescript_plugin,
                    languages = {'javascript', 'typescript', 'vue'}
                  },
                }
              },
              root_dir = lspconfig.util.root_pattern({ "package.json", "node_modules" }),
              filetypes = {
                'javascript',
                'javascriptreact',
                'javascript.jsx',
                'typescript',
                'typescriptreact',
                'typescript.tsx',
                'vue',
              },
            })
          end,

          lua_ls = function()
            require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
          end,
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
