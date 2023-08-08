require('nvim-treesitter.configs').setup({
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = {
        "bash",
        "c",
        "dockerfile",
        "go",
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
