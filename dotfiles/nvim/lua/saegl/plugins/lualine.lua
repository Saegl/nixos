return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local filename = {
                'filename',
                newfile_status = true,
                path = 1, -- Relative path
            }
            local fileformat = {
                'fileformat',
                icons_enabled = true,
                symbols = {
                    unix = 'LF',
                    dos = 'CRLF',
                    mac = 'CR',
                },
            }

            require('lualine').setup {
                options = {
                    component_separators = '|',
                    section_separators = '',
                    globalstatus = true,

                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { filename },
                    lualine_x = { 'encoding', fileformat, 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                extensions = {
                    "lazy",
                    "neo-tree",
                    "nvim-dap-ui",
                    "toggleterm",
                }
            }
        end,
    },
}
