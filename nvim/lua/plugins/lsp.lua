return {

  {
    'L3MON4D3/LuaSnip',
    event = 'VeryLazy',
    opts = {
      history = true,
      delete_check_events = 'TextChanged',
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
      local luasnip = require('luasnip')

      luasnip.setup({})

      cmp.setup({
        sources = {
          { name = 'lazydev', group_index = 0 },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'buffer', keyword_length = 5 },
        },
        formatting = {
          expandable_indicator = true,
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, item)
            return require('lspkind').cmp_format({
              mode = 'symbol',
            })(entry, item)
          end
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end
        },
        window = {
          documentation = cmp.config.window.bordered {
            winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None',
          },
        },
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
          ['<C-space>'] = cmp.mapping.complete(),
          ['<Esc>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true
          }),

          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        })
      })
    end
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'nvim-cmp' },
      -- { 'hrsh7th/cmp-nvim-lsp' }
    },
    config = function ()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function (event)
          local telescope_builtin = require('telescope.builtin')
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc, remap = false })
          end

          map('gd', telescope_builtin.lsp_definitions, '[G]oto [D]efinition')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          map('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')
          map('gI', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')

          map('<leader>D', telescope_builtin.lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', telescope_builtin.lsp_document_symbols, '[D]ocument [S]ymbols')

          map('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
        end
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      require('mason').setup({})

      local servers = {
        nginx_language_server = {},

        emmet_ls = {},
        html = {},
        cssls = {},
        tailwindcss = {},

        intelephense = {},
        eslint = {},
        tsserver = {},
        svelte = {},
        volar = {},

        jsonls = {},
        yamlls = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})

      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })

      require('mason-lspconfig').setup({
        ensure_installed = ensure_installed,
        handlers = {
          function (server_name)
            local config = servers[server_name] or {}

            if server_name == 'tsserver' then
              server_name = 'ts_ls'
            end

            config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})

            require('lspconfig')[server_name].setup(config)
          end,
        }
      })
    end
  }

  -- {
  --   'VonHeikemen/lsp-zero.nvim',
  --   branch = 'v3.x',
  --   event = { 'BufReadPre', 'BufNewFile' },
  --   dependencies = {
  --     { 'neovim/nvim-lspconfig' },
  --     { 'williamboman/mason.nvim' },
  --     { 'williamboman/mason-lspconfig.nvim' },
  --     { 'nvim-cmp' },
  --   },
  --   init = function()
  --     vim.diagnostic.config({
  --       virtual_text = true
  --     })
  --   end,
  --   config = function()
  --     local lsp_zero = require('lsp-zero')
  --     local mason_lspconfig = require('mason-lspconfig')

  --     require('mason').setup({})

  --     local nmap = function(buffer, keys, func, desc)
  --       if desc then
  --         desc = 'LSP: ' .. desc
  --       end
  --       vim.keymap.set('n', keys, func, { buffer = buffer, desc = desc, remap = false })
  --     end

  --     mason_lspconfig.setup({
  --       ensure_installed = {
  --         'emmet_ls',
  --         'jsonls',
  --         'html',
  --         'cssls',
  --         'tailwindcss',
  --         'svelte',
  --         'lua_ls',
  --         'eslint',
  --         'volar',
  --       },
  --       handlers = {
  --         -- lsp_zero.default_setup,

  --         function (server_name)
  --           require('lspconfig')[server_name].setup({})
  --         end,

  --         -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#volar
  --         volar = function()
  --           local util = require('lspconfig.util')
  --           local global_lib = '/opt/homebrew/lib/node_modules/typescript/lib'

  --           local function get_ts_server_path(root_dir)
  --             local found_lib = ''
  --             local function check_dir(path)
  --               found_lib = util.path.join(path, 'node_modules', 'typescript', 'lib')
  --               if util.path.exists(found_lib) then
  --                 return path
  --               end
  --             end

  --             if util.search_ancestors(root_dir, check_dir) then
  --               return found_lib
  --             else
  --               return global_lib
  --             end
  --           end

  --           require('lspconfig').volar.setup({
  --             filetypes = { 'vue', 'typescript', 'javascript' },
  --             init_options = {
  --               tsdk = '/opt/homebrew/lib/node_modules/typescript/lib'
  --             },
  --             on_new_config = function(new_config, new_root_dir)
  --               new_config.init_options.typescript.tsdk = get_ts_server_path(new_root_dir)
  --             end,
  --           })
  --         end,

  --         tsserver = function()
  --           local lspconfig = require('lspconfig')
  --           local vue_typescript_plugin = require('mason-registry')
  --             .get_package('vue-language-server')
  --             :get_install_path()
  --             .. '/node_modules/@vue/language-server'
  --             .. '/node_modules/@vue/typescript-plugin'

  --           lspconfig.ts_ls.setup({
  --             init_options = {
  --               plugins = {
  --                 {
  --                   name = "@vue/typescript-plugin",
  --                   location = vue_typescript_plugin,
  --                   languages = {'javascript', 'typescript', 'vue'}
  --                 },
  --               }
  --             },
  --             root_dir = lspconfig.util.root_pattern({ "package.json", "node_modules" }),
  --             filetypes = {
  --               'javascript',
  --               'javascriptreact',
  --               'javascript.jsx',
  --               'typescript',
  --               'typescriptreact',
  --               'typescript.tsx',
  --               'vue',
  --             },
  --           })
  --         end,

  --         lua_ls = function()
  --           require('lspconfig').lua_ls.setup(lsp_zero.nvim_lua_ls())
  --         end,
  --       }
  --     })

  --     lsp_zero.on_attach(function(_, buffer)
  --       lsp_zero.default_keymaps({ buffer = buffer })

  --       nmap(buffer, '<leader>ca', vim.lsp.buf.code_action, 'Code Action')
  --     end)

  --     lsp_zero.setup_servers({})
  --   end
  -- },

}
