return {
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        enabled = true,
        config = function()
            local filename = {
                'filename',
                newfile_status = true,
                path = 1, -- Relative path
            }

            local fileformat = {
                function()
                    local fmt = vim.bo.fileformat
                    return fmt ~= "unix" and fmt:upper() or ""
                end,
                icons_enabled = false,
            }

            local encoding = {
                function()
                    local enc = vim.bo.fileencoding
                    return enc ~= "utf-8" and enc or ""
                end
            }

            local function opened_terminals()
                local terms = require("toggleterm.terminal").get_all()
                local term_names = {}
                for _, term in ipairs(terms) do
                    table.insert(term_names, "T" .. term.id)
                end
                return table.concat(term_names, " | ")
            end

            -- local theme = require('custom_theme.oh-lucy')

            require('lualine').setup {
                options = {
                    -- theme = theme,
                    component_separators = '|',
                    section_separators = '',
                    globalstatus = true,

                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch' },
                    lualine_c = { opened_terminals, filename },
                    lualine_x = { encoding, fileformat },
                    -- lualine_y = {},
                    -- lualine_z = {}
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
