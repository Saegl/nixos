return {
    'ThePrimeagen/vim-be-good',
    'tpope/vim-sleuth',                     -- Detect tabstop and shiftwidth automatically
    { 'numToStr/Comment.nvim', opts = {} }, -- Add comments with 'gcc'
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = { signs = false }
    },
    {
        -- To enable :ColorizerToggle
        'norcalli/nvim-colorizer.lua',
        opts = {},
    },
    {
        "cbochs/portal.nvim",
        opts = {},
        keys = {
            {
                '<leader>i',
                "<cmd>Portal jumplist forward<cr>",
                mode = 'n',
                desc = 'Portal jumplist forward',
            },
            {
                '<leader>o',
                "<cmd>Portal jumplist backward<cr>",
                mode = 'n',
                desc = 'Portal jumplist backward',
            },
        },
    },
    {
        'Eandrju/cellular-automaton.nvim'
    },
    {
        'stevearc/aerial.nvim',
        opts = {
            on_attach = function(bufnr)
                vim.keymap.set("n", "<C-Up>", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                vim.keymap.set("n", "<C-Down>", "<cmd>AerialNext<CR>", { buffer = bufnr })
            end
        },
        -- Optional dependencies
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },
    {
        "m00qek/baleia.nvim",
        version = "*",
        config = function()
            vim.g.baleia = require("baleia").setup({})

            -- Command to colorize the current buffer
            vim.api.nvim_create_user_command("BaleiaColorize", function()
                vim.g.baleia.once(vim.api.nvim_get_current_buf())
            end, { bang = true })

            -- Command to show logs
            vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
        end,
    }
}
