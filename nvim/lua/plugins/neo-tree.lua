return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    dependencies = {
      'plenary.nvim',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      {
        '<leader>ge',
        function()
          require('neo-tree.command').execute({ source = 'git_status', toggle = true })
        end,
        desc = 'Git explorer'
      },

      {
        '<leader>be',
        function()
          require('neo-tree.command').execute({ source = 'buffers', toggle = true })
        end,
        desc = 'Buffers explorer'
      }
    },
    deactivate = function ()
      vim.cmd([[Neotree close]])
    end,
    init = function ()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then
          require('neo-tree')
        end
      end

      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- If you want icons for diagnostic errors, you'll need to define them somewhere:
      vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

      vim.keymap.set('n', '<C-b>', ':Neotree toggle<CR>')
    end,
    opts = {
      sources = { 'filesystem', 'buffers', 'git_status', 'document_symbols' },
      enable_git_status = true,
      popup_border_style = "rounded",
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        file_size = {
          enabled = true,
          required_width = 64, -- min width of window required to show this column
        },
        type = {
          enabled = true,
          required_width = 122, -- min width of window required to show this column
        },
        last_modified = {
          enabled = true,
          required_width = 88, -- min width of window required to show this column
        },
        created = {
          enabled = true,
          required_width = 110, -- min width of window required to show this column
        },
        symlink_target = {
          enabled = true,
        },
      },
      window = {
        position = 'float'
      },
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            'node_modules',
          },
          hide_by_pattern = {},
          always_show = {
            -- '.env'
          },
          never_show = {
            '.git',
            '.DS_Store',
            'thumbs.db',
            'Desktop.ini',
            '.directory'
          },
          never_show_by_pattern = {
            '*~',
            '*.swp',
            '*.bin',
            '*.exe',
            '*.out',
          },
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
        window = {
          mappings = {
            ['.'] = 'set_root',
            ['<bs>'] = 'navigate_up',
            ['H'] = 'toggle_hidden',
          },
          fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
            ["<down>"] = "move_cursor_down",
            ["<up>"] = "move_cursor_up",
          },
        },
      },
      buffers = {
        follow_current_files = {
          enabled = true,
        },
        window = {
          mappings = {
            ['.'] = 'set_root',
            ['<bs>'] = 'navigate_up',
            ['bd'] = 'buffer_delete',
          }
        },
      },
      git_status = {},
    },
    config = function (_, opts)
      require('neo-tree').setup(opts)

      vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*lazygit',
        callback = function ()
          if package.loaded['neo-tree.source.git_status'] then
            require('neo-tree.source.git_status').refresh()
          end
        end
      })
    end
  }
}
