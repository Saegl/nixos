return {
    {
        'mfussenegger/nvim-dap',
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            vim.cmd("hi DapBreakpointColor guifg=#fa4848")
            vim.fn.sign_define("DapBreakpoint", {
                text = "",
                texthl = "DapBreakpointColor",
                linehl = "",
                numhl = "",
            })

            vim.cmd("hi DapStopped guifg=#fa4848")
            vim.fn.sign_define('DapStopped', {
                text = '',
                texthl = 'DapStopped',
                linehl = '',
                numhl = '',
            })

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


            local function set_debug_keymaps()
                vim.keymap.set('n', '<Right>', dap.step_into, { desc = 'DAP Step Into' })
                vim.keymap.set('n', '<Left>', dap.step_out, { desc = 'DAP Step Out' })
                vim.keymap.set('n', '<Down>', dap.step_over, { desc = 'DAP Step Over' })
                vim.keymap.set('n', '<Up>', dap.step_back, { desc = 'DAP Step Back' })
            end

            local function clear_debug_keymaps()
                pcall(vim.keymap.del, 'n', '<Right>')
                pcall(vim.keymap.del, 'n', '<Left>')
                pcall(vim.keymap.del, 'n', '<Down>')
                pcall(vim.keymap.del, 'n', '<Up>') -- in case it was set
            end

            -- Setup event listeners
            dap.listeners.after.event_initialized["debug_keys"] = function()
                set_debug_keymaps()
            end

            dap.listeners.before.event_terminated["debug_keys"] = function()
                clear_debug_keymaps()
            end

            dap.listeners.before.event_exited["debug_keys"] = function()
                clear_debug_keymaps()
            end

            vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = "[D]ebug [U]I toggle" })
            vim.keymap.set('n', '<leader>B', dap.run_to_cursor, { desc = "Dap continue" })

            vim.keymap.set('n', '<F1>', dap.continue, { desc = "Dap continue" })
            vim.keymap.set('n', '<F2>', dap.toggle_breakpoint,
                { desc = "Toggle breakpoint" })
            vim.keymap.set('n', '<F3>',
                function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end,
                { desc = "Breakpoint log message" })


            -- vim.keymap.set({ 'n', 'v' }, '<F4>', function()
            --     require('dap.ui.widgets').hover()
            -- end)

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
