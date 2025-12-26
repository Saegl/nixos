return {
    {
        "EdenEast/nightfox.nvim",
        enabled = false,
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
    },
    {
        "rebelot/kanagawa.nvim",
        enabled = false,
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'kanagawa-dragon'
        end,
    },
    {
        "ellisonleao/gruvbox.nvim",
        enabled = false,
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'gruvbox'
        end,
    },
    {
        "scottmckendry/cyberdream.nvim",
        enabled = false,
        lazy = false,
        priority = 1000,
        config = function()
            require('cyberdream').setup {
                transparent = true,
            }
            vim.cmd.colorscheme 'cyberdream'

            -- Define a custom highlight group for terminal background
            vim.api.nvim_set_hl(0, "MyTerminalNormal", { bg = "#000000" }) -- Choose a dark bg

            -- Set that highlight only for terminal windows
            vim.api.nvim_create_autocmd("TermOpen", {
                callback = function()
                    vim.opt_local.winhighlight = "Normal:MyTerminalNormal"
                end,
            })

            -- Inside your config function after setting colorscheme
            vim.g.terminal_color_0 = "#1a1a1a" -- black
            vim.g.terminal_color_8 = "#aaaaaa" -- bright black (fish suggestion gray)
        end,
    },
    {
        "yazeed1s/oh-lucy.nvim",
        enabled = true,
        priority = 1000,
        config = function()
            vim.g.oh_lucy_evening_transparent_background = true

            vim.opt.termguicolors = true
            vim.cmd.colorscheme 'oh-lucy-evening'

            -- -- Set main background to pure black
            -- vim.cmd("highlight Normal guibg=#000000 guifg=NONE")
            -- vim.cmd("highlight NormalNC guibg=#000000 guifg=NONE")
            -- vim.cmd("highlight SignColumn guibg=#000000")
            -- vim.cmd("highlight LineNr guibg=#000000")
            -- vim.cmd("highlight VertSplit guibg=#000000 guifg=#000000")
            -- vim.cmd("highlight StatusLine guibg=#000000")
            --
            -- -- Optional: Update other elements to match the black background
            -- vim.cmd("highlight WinSeparator guibg=#000000 guifg=#000000")
            -- vim.cmd("highlight NeoTreeNormalNC guibg=#000000")
            -- vim.cmd("highlight PmenuSel guibg=#282933 guifg=NONE")
            -- vim.cmd("highlight TelescopeSelection guibg=#282933 guifg=NONE")
            -- vim.cmd("highlight Visual guibg=#3b4252 guifg=NONE")

            vim.cmd("highlight WinSeparator guibg=bg guifg=bg")

            vim.cmd("highlight WinSeparator guibg=bg guifg=bg")
            vim.cmd("highlight NeoTreeNormalNC guibg=#1A191E")

            vim.cmd("highlight PmenuSel guibg=#282933 guifg=NONE")                 -- Brighter gray for selected item in completion menu
            vim.cmd("highlight TelescopeSelection guibg=#282933 guifg=NONE")       -- Brighter selection in telescope

            vim.cmd("highlight Visual guibg=#3b4252 guifg=NONE")                   -- Brighter selection in telescope

            vim.cmd("highlight FlashBackdrop guifg=#686069")                       -- comment color
            vim.cmd("highlight FlashMatch guibg=#EFD472 guifg=#1E1D23 gui=bold")   -- yellow bg, dark fg, bold
            vim.cmd("highlight FlashCurrent guibg=#FF7DA3 guifg=#1E1D23 gui=bold") -- pink/red bg, dark fg, bold
            vim.cmd("highlight FlashLabel guibg=#BDA9D4 guifg=#1E1D23 gui=bold")   -- pink bg, dark fg, bold
            vim.cmd("highlight FlashPrompt guibg=#29292E guifg=#DED7D0")           -- dark bg, light fg
            vim.cmd("highlight FlashPromptIcon guifg=#E39A65 gui=bold")            -- orange fg, bold
            vim.cmd("highlight FlashCursor guibg=#BBBBBB guifg=#1E1D23")           -- accent bg, dark fg
        end
    },
    {
        'kdheepak/monochrome.nvim',
        enabled = false,
        priority = 1000,
        config = function()
            -- vim.opt.termguicolors = true
            vim.cmd.colorscheme 'monochrome'
        end
    },
    {
        'sainnhe/gruvbox-material',
        enabled = false,
        priority = 1000,
        config = function()
            vim.opt.termguicolors = true
            vim.g.gruvbox_material_background = "hard"
            vim.g.gruvbox_material_foreground = "original"
            vim.cmd.colorscheme 'gruvbox-material'
        end
    }
}
