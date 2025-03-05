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

vim.keymap.set('n', '<leader>o', function() open_python_stacktrace_line() end, { desc = "Open under cursor" })


local function custom_python_indent()
    local prevline = vim.fn.getline(vim.fn.line('.') - 1)
    local prevline_indent = vim.fn.indent(vim.fn.line('.') - 1)

    -- increase indent
    if prevline:match(":$") or prevline:match("{$") or prevline:match("%($") or prevline:match("%[$") then
        return prevline_indent + vim.bo.shiftwidth
    end

    -- decrease indent
    if prevline:match("^%s*pass") or prevline:match("^%s*return") or prevline:match("^%s*break") then
        return prevline_indent - vim.bo.shiftwidth
    end

    -- don't change
    return -1
end

-- Expose the function globally
_G.custom_python_indent = custom_python_indent

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.bo.indentexpr = "v:lua.custom_python_indent()"
    end,
})
