return {

  {
    'rcarriga/nvim-dap-ui',
    lazy = true,
    dependencies = {
      { 'mfussenegger/nvim-dap', lazy = true },
      { 'nvim-neotest/nvim-nio' },
      { 'williamboman/mason.nvim' },
      { 'jay-babu/mason-nvim-dap.nvim' },
      { 'stevearc/dressing.nvim' },
    },
    keys = function(_, keys)
      local dap = require('dap')
      local dapui = require('dapui')

      return {
        { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
        { '<F1>', dap.step_into, desc = 'Debug: Step into' },
        { '<F2>', dap.step_over, desc = 'Debug: Step over' },
        { '<F3>', dap.step_out, desc = 'Debug: Step out' },
        { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
        { '<F7>', dapui.toggle, desc = 'Debug: Toggle UI' },
        unpack(keys),
      }
    end,
    opts = function() return {} end,
    config = function(_, opts)
      local dap = require('dap')
      local dapui = require('dapui')
      local mason_dap = require('mason-nvim-dap')

      mason_dap.setup({
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
          function(config) mason_dap.default_setup(config) end,

          -- https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#php
          ---@param config table
          php = function(config)
            config.adapters = {
              type = 'executable',
              command = 'php-debug-adapter',
            }

            mason_dap.default_setup(config)
          end,
        },
      })

      dapui.setup(opts)

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
}
