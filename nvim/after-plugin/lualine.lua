local lualine = require('lualine')
--local colors = require('ayu.colors')

local diagnostics = {
    'diagnostics',
    symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
    --diagnostics_color = {
    --    error = { fg = colors.error },
    --    warning = { fg = colors.warning },
    --    info = { fg = colors.tag },
    --    hint = { fg = colors.regexp },
    --}
}

lualine.setup({
    options = {
        component_separators = '',
        section_separators = '',
        theme = 'ayu'
    },
    sections = {
        lualine_b = { 'branch', 'diff', diagnostics },
        lualine_x = { 'encoding', 'fileformat' },
        lualine_y = { 'filetype', 'progress' },
        lualine_z = { 'location' }
    }
})
