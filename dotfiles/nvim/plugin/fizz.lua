vim.filetype.add({
    extension = {
        fizz = "fizz"
    }
})

local syntax = vim.api.nvim_create_augroup('FizzSyntax', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
    group = syntax,
    pattern = 'fizz',
    callback = function()
        vim.cmd('syntax on')

        vim.cmd('syntax keyword fizzKeyword import from as return struct union fn let if elif else')
        vim.cmd('syntax match fizzString /".*"/')
        vim.cmd('syntax match fizzComment /^\\s*#.*$/')
        vim.cmd('syntax match fizzNumber /\\v\\d+\\.?\\d*/')

        vim.cmd('highlight link fizzKeyword Keyword')
        vim.cmd('highlight link fizzString String')
        vim.cmd('highlight link fizzComment Comment')
        vim.cmd('highlight link fizzNumber Number')
    end,
})

-- Ensure filetype is reapplied on BufWinEnter to maintain syntax
vim.api.nvim_create_autocmd('BufWinEnter', {
    group = syntax,
    pattern = '*.fizz',              -- Match your custom file extension
    callback = function()
        vim.cmd('set filetype=fizz') -- Reapply the filetype
    end,
})
