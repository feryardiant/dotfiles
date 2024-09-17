return {

  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'MunifTanjim/nui.nvim' },
    },
    keys = {
      {
        '<leader>ge',
        function() require('neo-tree.command').execute({ source = 'git_status', position = 'float', toggle = true }) end,
        desc = 'Git explorer',
      },

      {
        '<leader>be',
        function() require('neo-tree.command').execute({ source = 'buffers', position = 'float', toggle = true }) end,
        desc = 'Buffers explorer',
      },

      {
        '<leader>fe',
        function() require('neo-tree.command').execute({ source = 'filesystem', position = 'float', toggle = true }) end,
        desc = 'File explorer',
      },
    },
    deactivate = function() vim.cmd([[Neotree close]]) end,
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then require('neo-tree') end
      end

      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      -- If you want icons for diagnostic errors, you'll need to define them somewhere:
      vim.fn.sign_define('DiagnosticSignError', { text = ' ', texthl = 'DiagnosticSignError' })
      vim.fn.sign_define('DiagnosticSignWarn', { text = ' ', texthl = 'DiagnosticSignWarn' })
      vim.fn.sign_define('DiagnosticSignInfo', { text = ' ', texthl = 'DiagnosticSignInfo' })
      vim.fn.sign_define('DiagnosticSignHint', { text = '󰌵', texthl = 'DiagnosticSignHint' })
    end,
    opts = {
      popup_border_style = 'rounded',
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
        created = {
          enabled = true,
        },
        symlink_target = {
          enabled = true,
        },
      },
      source_selector = {
        winbar = true,
        statusline = true,
        content_layout = 'center',
      },
      window = {
        position = 'current',
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            'node_modules',
            'vendor',
          },
          hide_by_pattern = {
            '*.old',
            '._*',
          },
          never_show = {
            '.DS_Store',
            '.directory',
            '.git',
            'Desktop.ini',
            'thumbs.db',
          },
          never_show_by_pattern = {
            '*~',
            '*.bin',
            '*.exe',
            '*.out',
            '*.swp',
          },
        },
        use_libuv_file_watcher = true,
      },
      document_symbols = {
        follow_cursor = true,
      },
    },
    config = function(_, opts)
      require('neo-tree').setup(opts)

      vim.api.nvim_create_autocmd('TermClose', {
        pattern = '*lazygit',
        callback = function()
          if package.loaded['neo-tree.source.git_status'] then require('neo-tree.source.git_status').refresh() end
        end,
      })
    end,
  },
}
