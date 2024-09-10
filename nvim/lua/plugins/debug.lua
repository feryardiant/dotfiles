return {

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    keys = function (_, keys)
      local dap = require('dap')
      local dapui = require('dapui')

      return {
        { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
        { '<F1>', dap.step_into, desc = 'Debug: Step into' },
        { '<F2>', dap.step_over, desc = 'Debug: Step over' },
        { '<F3>', dap.step_out, desc = 'Debug: Step out' },
        { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
        { '<F7>', dapui.toggle, desc = 'Debug: Toggle UI' },
        unpack(keys)
      }
    end,
    config = function ()
      local dap = require('dap')
      local dapui = require('dapui')

      ---Retrieve mason package install path
      ---@param package_name string
      ---@param path string
      ---@return string
      local function get_mason_pkg_path (package_name, path)
        local util = require('lspconfig.util')

        return util.path.join(
          require('mason-registry').get_package(package_name):get_install_path(),
          path
        )
      end

      require('mason-nvim-dap').setup({
        automatic_installation = true,
        ensure_installed = {
          'chrome-debug-adapter',
          'firefox-debug-adapter',
          'php-debug-adapter',
          'js-debug-adapter',
          'node-debug2-adapter',
        },
        handlers = {
          -- all sources with no handler get passed here
          -- see https://github.com/jay-babu/mason-nvim-dap.nvim?tab=readme-ov-file#advanced-customization
          function (config)
            require('mason-nvim-dap').default_setup(config)
          end,

          -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#php
          ---@param config table
          php = function (config)
            config.adapters = {
              type = 'executable',
              command = 'node',
              args = {
                get_mason_pkg_path('php-debug-adapter', 'extension/out/phpDebug.js'),
              }
            }

            require('mason-nvim-dap').default_setup(config)
          end
        }
      })

      dapui.setup({})

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end
  }

}
