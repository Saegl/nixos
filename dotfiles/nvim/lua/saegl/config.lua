-- Fast access to config
vim.api.nvim_create_user_command('Conf', function() vim.cmd(":edit $MYVIMRC") end, {})
vim.api.nvim_create_user_command('Line', function() vim.cmd(":echo line('.') . ':' . col('.')") end, {})
vim.api.nvim_create_user_command('Todo', function() vim.cmd(":edit ~/shared/notes/TODO.md") end, {})
vim.api.nvim_create_user_command('Today', function(opts)
    local offset = tonumber(opts.args) or 0

    local target_time = os.time() + (offset * 86400)
    local date = os.date("%Y-%m-%d", target_time)
    local path = "~/shared/notes/daily/" .. date .. ".md"
    vim.cmd(":edit " .. path)
end, {
    nargs = "?",
    complete = function()
        return { "-2", "-1", "0", "1", "2" }
    end
})

vim.lsp.set_log_level("ERROR") -- I don't care about deprected notifications

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
