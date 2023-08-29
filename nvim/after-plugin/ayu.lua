--vim.cmd.colorscheme('ayu')

local colors = require('ayu.colors')
local ayu = require('ayu')

colors.generate()

ayu.setup({
    overrides = function()
        return {
            Normal = { bg = 'none' },
            NormalFloat = { bg = '#3a3a3a' },
            SignColumn = { bg = 'none' },
            Comment = { fg = colors.comment },
            CursorLine = { bg = '#1c1c1c' },
            CursorLineNr = { bg = '#1c1c1c', fg = colors.accent },
            ColorColumn = { bg = '#262626' },
            Pmenu = { bg = colors.selection_inactive },
            PmenuSel = { bg = colors.selection_bg },
            Visual = { bg = colors.selection_bg },
        }
    end
})

ayu.colorscheme()
