return {
    {
        'akinsho/bufferline.nvim',
        enabled = true,
        opts = {
            options = {
                mode = "buffers",
                numbers = "ordinal",
                -- Don't use icons
                -- If you still want to close with mouse
                -- use right click
                show_buffer_close_icons = false,
                middle_mouse_command = "bdelete! %d",
                separator_style = { "", "" }, -- Empty strings completely remove separators

                modified_icon = "M",
                offsets = {
                    {
                        filetype = "neo-tree",
                        text = "Explorer",
                        highlight = "Directory",
                        text_align = 'left',
                    }
                },

                persist_buffer_sort = false,

                always_show_bufferline = true,
                auto_toggle_bufferline = true,

                sort_by = 'insert_at_end',
            },
            highlights = function()
                -- local lucy_colors = require('oh-lucy-evening.colors')

                return {
                    -- buffer_selected = {
                    --     fg = lucy_colors.blue_type,
                    --     bg = lucy_colors.bg,
                    --     bold = false,
                    --     italic = false
                    -- },
                    -- numbers = {
                    --     fg = lucy_colors.white,
                    --     bg = lucy_colors.bg,
                    -- },
                    -- numbers_visible = {
                    --     fg = lucy_colors.white,
                    --     bg = lucy_colors.bg,
                    -- },
                    -- numbers_selected = {
                    --     fg = lucy_colors.white,
                    --     bg = lucy_colors.bg,
                    --     bold = false,
                    --     italic = false,
                    -- },
                    -- indicator_visible = {
                    --     fg = lucy_colors.bg,
                    --     bg = lucy_colors.bg,
                    -- },
                    -- indicator_selected = {
                    --     fg = lucy_colors.bg,
                    --     bg = lucy_colors.bg,
                    -- },
                }
            end,
        },


        config = function(_, opts)
            local bufferline = require 'bufferline'
            opts.options.style_preset = bufferline.style_preset.minimal
            bufferline.setup(opts)
            vim.keymap.set(
                'n',
                '<leader>bd',
                '<cmd>bd<cr>',
                { desc = "Close buffer" }
            )
            vim.keymap.set(
                'n',
                '<leader>bp',
                '<cmd>BufferLinePick<cr>',
                { desc = "Pick buffer" }
            )
            vim.keymap.set(
                'n',
                '<leader>bc',
                '<cmd>BufferLinePickClose<cr>',
                { desc = "Pick buffer to close" }
            )
            vim.keymap.set(
                'n',
                '<leader>bo',
                '<cmd>BufferLineCloseOthers<cr>',
                { desc = "Close other buffers" }
            )
            vim.keymap.set(
                'n',
                '<leader>bn',
                '<cmd>BufferLineTogglePin<cr>',
                { desc = "Pin current buffer" }
            )
            vim.keymap.set(
                'n',
                '<leader>bu',
                '<cmd>BufferLineGroupClose ungrouped<cr>',
                { desc = "Close ungrouped" }
            )

            -- vim.keymap.set(
            --     'n',
            --     '<Tab>',
            --     '<cmd>BufferLineCycleNext<cr>',
            --     { desc = "Next buffer" }
            -- )
            vim.keymap.set(
                'n',
                '<S-Tab>',
                '<cmd>BufferLineCyclePrev<cr>',
                { desc = "Previous buffer" }
            )

            for i = 1, 9, 1 do
                vim.keymap.set(
                    'n',
                    '<M-' .. i .. '>',
                    function() bufferline.go_to(i, true) end,
                    { desc = "Open buffer " .. i }
                )
                vim.keymap.set(
                    'n',
                    '<leader>bm' .. i,
                    function() bufferline.move_to(i) end,
                    { desc = "Move buffer to " .. i }
                )
            end
        end,
    },
}
