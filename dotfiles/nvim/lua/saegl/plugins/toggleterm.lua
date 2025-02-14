return {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
        size = 20,
        open_mapping = [[<c-`>]],
    },
    config = function(_, opts)
        local toggleterm = require 'toggleterm'
        toggleterm.setup(opts)

        local Terminal = require('toggleterm.terminal').Terminal

        function PyTerm()
            local name = vim.api.nvim_buf_get_name(0)
            local python = Terminal:new({
                cmd = ("python -i " .. name),
                display_name = name,
                direction = "float",
            })
            python:toggle()
        end

        vim.keymap.set('n', '<leader>xp', '<cmd>lua PyTerm()<cr>')
        vim.keymap.set('n', 'v<C-`>', '<cmd>ToggleTerm direction=vertical<cr>')
    end,
}
