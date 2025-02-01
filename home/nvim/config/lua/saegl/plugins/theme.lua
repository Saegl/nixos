return {
    {
        'rose-pine/neovim',
        name = 'rose-pine',
        priority = 1000,
        config = function()
            require("rose-pine").setup({
                variant = "main",
                highlight_groups = {
                    TelescopeBorder = { fg = "highlight_high", bg = "none" },
                    TelescopeNormal = { bg = "none" },
                    TelescopePromptNormal = { bg = "base" },
                    TelescopeResultsNormal = { fg = "subtle", bg = "none" },
                    TelescopeSelection = { fg = "text", bg = "base" },
                    TelescopeSelectionCaret = { fg = "rose", bg = "rose" },
                },
                styles = {
                    transparency = false,
                },
            })

            -- vim.cmd('colorscheme rose-pine')
        end,
    },
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            require('kanagawa').setup {
                theme = 'dragon',
                background = {
                    dark = 'dragon',
                }
            }
        end,
    },
    {
        "nyoom-engineering/oxocarbon.nvim",
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme "oxocarbon"
        end,
    },
    {
        'sainnhe/sonokai',
        lazy = false,
        priority = 1000,
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.sonokai_style = 'andromeda'
            vim.g.sonokai_enable_italic = true
            -- vim.cmd.colorscheme('sonokai')
        end
    },
    {
        'AlexvZyl/nordic.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            -- require 'nordic'.load()
        end
    },
    {
        'mcchrish/zenbones.nvim',
        priority = 1000,
        dependencies = {
            "rktjmp/lush.nvim",
        },
        config = function()
            -- vim.cmd.colorscheme('tokyobones')
        end,
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme "catppuccin-mocha"
        end,
    },
    {
        'Yazeed1s/oh-lucy.nvim',
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme "oh-lucy-evening"
        end,
    },
    {
        "HoNamDuong/hybrid.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            -- vim.cmd.colorscheme "hybrid"
        end,
    },
    {
        'projekt0n/github-nvim-theme',
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require('github-theme').setup({
                -- ...
            })

            -- vim.cmd('colorscheme github_dark_tritanopia')
            -- vim.cmd('colorscheme github_dark_high_contrast')
        end,
    },
    {
        'marko-cerovac/material.nvim',
        lazy = true,
        priority = 1000,
        config = function()
            vim.g.material_style = "deep ocean"
            -- vim.cmd.colorscheme 'material'
        end,
    },
    {
        'olivercederborg/poimandres.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('poimandres').setup {
                -- leave this setup function empty for default config
                -- or refer to the configuration section
                -- for configuration options
            }
            -- vim.cmd.colorscheme "poimandres"
        end,
    },
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
