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
            Pmenu = { bg = '#303030' },
            PmenuSel = { bg = '#3a3a3a' }
        }
    end
})

ayu.colorscheme()
