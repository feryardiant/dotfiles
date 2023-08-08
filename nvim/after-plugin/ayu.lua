--vim.cmd.colorscheme('ayu')

local colors = require('ayu.colors')
local ayu = require('ayu')

colors.generate()

ayu.setup({
    overrides = function()
        return {
            Comment = { fg = colors.comment }
        }
    end
})

ayu.colorscheme()
