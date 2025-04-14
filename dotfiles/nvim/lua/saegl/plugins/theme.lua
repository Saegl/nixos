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
            -- vim.cmd.colorscheme 'carbonfox'
        end,
    },
    {
        "yazeed1s/oh-lucy.nvim",
        priority = 1000,
        config = function()
            vim.opt.termguicolors = true
            vim.cmd.colorscheme 'oh-lucy-evening'
            vim.cmd("highlight WinSeparator guibg=bg guifg=bg")
            vim.cmd("highlight NeoTreeNormalNC guibg=#1A191E")

            vim.cmd("highlight PmenuSel guibg=#282933 guifg=NONE")           -- Brighter gray for selected item in completion menu
            vim.cmd("highlight TelescopeSelection guibg=#282933 guifg=NONE") -- Brighter selection in telescope

            vim.cmd("highlight Visual guibg=#3b4252 guifg=NONE")             -- Brighter selection in telescope
        end
    }
}
