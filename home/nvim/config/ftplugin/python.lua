local Path = require('plenary.path')

local function open_python_stacktrace_line()
    local line = vim.fn.getline('.')
    local file, lnum = line:match('File "([^"]+)", line (%d+)')
    if file and lnum then
        local file_path = Path:new(file):make_relative(vim.loop.cwd())
        vim.cmd('wincmd p')
        vim.cmd('edit +' .. lnum .. ' ' .. file_path)
    else
        print("No file and line information found on the current line")
    end
end

vim.keymap.set('n', '<leader>o', function() open_python_stacktrace_line() end)


-- is this even works?
vim.opt.autoindent = false
vim.opt.smartindent = false
vim.opt.copyindent = true
vim.opt.preserveindent = true
vim.opt.indentexpr = ""
