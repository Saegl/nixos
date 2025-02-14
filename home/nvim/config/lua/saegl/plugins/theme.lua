return {
    {
        "EdenEast/nightfox.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require('nightfox').setup {
                options = {
                    dim_inactive = false,
                    transparent = false,
                },
                groups = {
                    carbonfox = {
                        Visual = { bg = "#3b4252", fg = "NONE" },
                    },
                },
            }
            vim.cmd.colorscheme 'carbonfox'
        end,
    }
}
