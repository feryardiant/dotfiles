return {

  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'williamboman/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
    },
    -- keys = function (_, keys)
    --   local dap = require('dap')
    --   local dapui = require('dapui')
    --
    --   return {
    --     { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
    --     { '<F1>', dap.step_into, desc = 'Debug: Step into' },
    --     { '<F2>', dap.step_over, desc = 'Debug: Step over' },
    --     { '<F3>', dap.step_out, desc = 'Debug: Step out' },
    --     { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
    --     { '<F7>', dapui.toggle, desc = 'Debug: Toggle UI' },
    --     unpack(keys)
    --   }
    -- end,
    config = function ()
      local dap = require('dap')
      local dapui = require('dapui')

      require('mason-nvim-dap').setup({
        automatic_installation = true,
        ensure_installed = {
          'chrome-debug-adapter',
          'firefox-debug-adapter',
          'php-debug-adapter',
          'js-debug-adapter',
          'node-debug2-adapter',
        }
      })

      dapui.setup({})

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end
  }

}
