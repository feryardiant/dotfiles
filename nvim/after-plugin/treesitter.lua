require('nvim-treesitter.configs').setup({
    -- https://github.com/windwp/nvim-ts-autotag
    autotag = {
        enable = true,
    },

    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = {
        "bash",
        "c",
        "dockerfile",
        "go",
        "html",
        "json",
        "javascript",
        "markdown",
        "markdown_inline",
        "lua",
        "php",
        "ruby",
        "rust",
        "scss",
        "sql",
        "svelte",
        "typescript",
        "toml",
        "vim",
        "vimdoc",
        "vue",
        "yaml",
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    indent = { enable = true },
    highlight = { enable = true },
})

-- https://github.com/EmranMR/tree-sitter-blade/discussions/19
-- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
--
-- parser_config.blade = {
--     install_info = {
--         url = 'https://github.com/EmranMR/tree-sitter-blade',
--         files = {'src/parser.c'},
--         branch = 'main'
--     },
--     filetype = 'blade'
-- }

-- https://github.com/EmranMR/tree-sitter-blade/discussions/19#discussioncomment-7036295
-- local bladeGrp vim.api.nvim_create_augroup("BladeFiltypeRelated", { clear = true })
-- vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' } , {
-- 	pattern = "*.blade.php",
-- 	group = bladeGrp,
-- 	callback = function()
-- 		vim.opt.filetype = "blade"
-- 	end,
-- })

