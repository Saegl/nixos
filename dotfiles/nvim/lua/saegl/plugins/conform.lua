return {
    { -- Autoformat
        'stevearc/conform.nvim',
        lazy = false,
        keys = {
            {
                '<leader>f',
                function()
                    require('conform').format { async = true, lsp_fallback = true }
                end,
                mode = '',
                desc = '[F]ormat buffer',
            },
        },
        opts = {
            notify_on_error = false,
            format_on_save = (function()
                local format_disabled_cache = {}

                return function(bufnr)
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                        return
                    end

                    local filetype = vim.bo[bufnr].filetype

                    if format_disabled_cache[filetype] == nil then
                        local config_filename = ".disable_format_" .. filetype
                        local root = vim.fn.getcwd() -- Replace with proper root detection if needed
                        local full_path = root .. "/" .. config_filename
                        format_disabled_cache[filetype] = vim.fn.filereadable(full_path) == 1
                    end

                    return {
                        timeout_ms = 500,
                        lsp_fallback = not format_disabled_cache[filetype],
                    }
                end
            end)(),
            formatters_by_ft = {
                -- Conform can also run multiple formatters sequentially
                -- python = { "isort", "black" },
                --
                -- You can use a sub-list to tell conform to run *until* a formatter
                -- is found.
                -- javascript = { { "prettierd", "prettier" } },
            },
        },
        config = function(_, opts)
            local conform = require 'conform'
            conform.setup(opts)

            vim.api.nvim_create_user_command("FormatDisable", function(args)
                vim.g.disable_autoformat = true
            end, {
                desc = "Disable autoformat-on-save",
            })
            vim.api.nvim_create_user_command("FormatFileDisable", function(args)
                vim.b.disable_autoformat = true
            end, {
                desc = "Disable autoformat-on-save for file",
            })
            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat = false
                vim.g.disable_autoformat = false
            end, {
                desc = "Re-enable autoformat-on-save",
            })
        end
    },
}
