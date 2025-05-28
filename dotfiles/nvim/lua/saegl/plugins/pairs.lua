return {
    {
        'echasnovski/mini.pairs',
        event = "VeryLazy",
        version = '*',
        keys = {
            {
                "<leader>tp",
                mode = "n",
                function()
                    vim.g.minipairs_disable = not vim.g.minipairs_disable
                end,
                desc = "toggle mini.pairs"
            }
        },
        config = function()
            vim.g.minipairs_disable = true
            require "mini.pairs".setup()
        end,
    },
    {
        'echasnovski/mini.surround',
        version = '*',
        opts = {
            -- In comparison to original mappings
            -- this mappings prefixed with "g" to avoid collision with
            -- motion plugins like flash or leap
            mappings = {
                add = 'gsa',            -- Add surrounding in Normal and Visual modes
                delete = 'gsd',         -- Delete surrounding
                find = 'gsf',           -- Find surrounding (to the right)
                find_left = 'gsF',      -- Find surrounding (to the left)
                highlight = 'gsh',      -- Highlight surrounding
                replace = 'gsr',        -- Replace surrounding
                update_n_lines = 'gsn', -- Update `n_lines`

                suffix_last = 'l',      -- Suffix to search with "prev" method
                suffix_next = 'n',      -- Suffix to search with "next" method
            },
        },
    },
}
