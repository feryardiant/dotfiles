local lsp = require('lsp-zero')
local lsp_config = require('lspconfig')

lsp.preset('recommended')

lsp.nvim_workspace()

lsp.on_attach(function(_, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    lsp.default_keymaps({ buffer = bufnr })

    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc, remap = false })
    end

    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
    nmap('gi', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
    nmap('<C-h>', vim.lsp.buf.signature_help, 'Get [H]elp')

    nmap('K', vim.lsp.buf.hover, '')
    -- nmap('<leader>vws', vim.lsp.buf.workspace_symbol)

    -- mmap('<leader>vd', vim.diagnostic.open_float)

    vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
        vim.lsp.buf.format({ async = true })
    end, { desc = 'Format current buffer with LSP' })
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})

local mason_lspconfig = require('mason-lspconfig')

local servers = {
    intelephense = {},
    jsonls = {},
    tsserver = {},
    svelte = {},
    volar = {},
    lua_ls = {},
}

mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers)
})

-- lsp_config.eslint.setup({
--    root_dir = function(fname)
--        util.root_pattern('package.json', 'tsconfig.json')(fname)
--    end,
-- })

lsp_config.intelephense.setup({
    settings = {
        intelephense = {
            files = {
                exclude = {
                    "**/.git/**",
                    "**/.svn/**",
                    "**/.hg/**",
                    "**/CVS/**",
                    "**/.DS_Store/**",
                    "**/node_modules/**",
                    "**/bower_components/**",
                    "**/vendor/**/{Tests,tests}/**",
                    "**/.history/**",
                    "**/vendor/**/vendor/**"
                }
            }
        }
    }
})

lsp_config.phpactor.setup({
    init_options = {
        ['language_server_phpstan.enabled'] = false,
        ['language_server_psalm.enabled'] = false,
    }
})

-- https://github.com/haringsrob/laravel-dev-tools/tree/main#neovim
lsp_config.blade = {
    default_config = {
        cmd = { "laravel-dev-generators", "lsp" },
        filetypes = {'blade'},
        root_dir = function(fname)
            return lsp_config.util.find_git_ancestor(fname)
        end,
        settings = {}
    }
}

lsp_config.lua_ls.setup(lsp.nvim_lua_ls())

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, item)
            return require('lspkind').cmp_format({
                mode = 'symbol',
                maxwidth = 50,
            })(entry, item)
        end,
    },
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'nvim_lsp_signature_help' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
    }),
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
    }),
})

