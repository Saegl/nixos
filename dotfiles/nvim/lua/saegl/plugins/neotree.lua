return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        keys = {
            { '\\', ':Neotree toggle float<CR>', { desc = 'NeoTree toggle' } },
        },
        opts = {
            close_if_last_window = true,
            filesystem = {
                window = {
                    mappings = {
                        ['\\'] = 'close_window',
                        ['<tab>'] = 'open',
                    },
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
            -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        }
    },
}
