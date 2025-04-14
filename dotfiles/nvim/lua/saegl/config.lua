-- Fast access to config
vim.api.nvim_create_user_command('Conf', function() vim.cmd(":edit $MYVIMRC") end, {})
vim.api.nvim_create_user_command('Line', function() vim.cmd(":echo line('.') . ':' . col('.')") end, {})
vim.api.nvim_create_user_command('Todo', function() vim.cmd(":edit ~/shared/notes/TODO.md") end, {})

-- Rage mode
vim.api.nvim_create_user_command('Q', function() vim.cmd(":q") end, {})

vim.diagnostic.config({
    virtual_text = false,
    float = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        style = 'minimal',
        border = 'rounded',
        source = true,
        header = '',
        prefix = '',
        scope = 'line',
    },
})
