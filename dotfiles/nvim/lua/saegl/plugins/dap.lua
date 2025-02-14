return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require('dap')
            local dapui = require('dapui')
            require("nvim-dap-virtual-text").setup {}
            dapui.setup()

            -- Auto open UI if it is not opened when starting dap
            dap.listeners.before.attach.dapui_config = function()
                dapui.open()
            end
            dap.listeners.before.launch.dapui_config = function()
                dapui.open()
            end

            vim.keymap.set('n', '<leader>du', dapui.toggle)
            vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
            vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end)
            vim.keymap.set('n', '<leader>dn', function() require('dap').step_over() end)
            vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end)
            vim.keymap.set('n', '<leader>do', function() require('dap').step_out() end)

            vim.keymap.set('n', '<Leader>db', function() require('dap').toggle_breakpoint() end)
            vim.keymap.set('n', '<Leader>dB',
                function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end)


            vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
                require('dap.ui.widgets').hover()
            end)

            dap.adapters.python = function(cb, config)
                cb({
                    type = 'executable',
                    command = '/etc/profiles/per-user/saegl/bin/python3.12',
                    args = { '-m', 'debugpy.adapter' },
                    options = {
                        source_filetype = 'python',
                    },
                })
            end
            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = "Launch file",

                    -- debugpy options below: https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
                    program = "${file}", -- This configuration will launch the current file if used.
                    pythonPath = function()
                        -- Use currently active python (global, venv, conda), trim whitespace
                        return vim.fn.system("which python"):gsub('%s+', '')
                    end,
                },
            }
        end,
    },
}
