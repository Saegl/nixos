return {
    "folke/snacks.nvim",
    opts = {
        indent = {
            only_current = true,
            only_scope = true,
            animate = {
                enabled = false,
            },
            scope = {
                enabled = false,
            }
        },
        -- notifier = {
        --     timeout = 0,
        -- },
        gitbrowse = {
        },
        scope = {
        },
        scroll = {
        },
        scracth = {
        }
    },
    config = function(_, opts)
        local snacks = require "snacks"
        snacks.setup(opts)

        local map = vim.keymap.set

        -- Show notifier history
        map("n", "<leader>ns", "<cmd>lua (function() Snacks.notifier.show_history() end)()<CR>",
            { desc = "Show notifier history" })

        -- Hide notifier
        map("n", "<leader>nh", "<cmd>lua Snacks.notifier.hide()<CR>", { desc = "Hide notifier" })

        -- Gitbrowse
        map("n", "<leader>sb", "<cmd>lua Snacks.gitbrowse()<CR>", { desc = "Gitbrowse" })

        map('n', "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
        map('n', "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
    end
    --  test
}
