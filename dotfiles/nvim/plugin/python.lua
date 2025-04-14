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

vim.keymap.set('n', '<leader>O', function() open_python_stacktrace_line() end, { desc = "Open under cursor" })

local function get_prev_non_empty_line_indent()
    local linenr = vim.fn.line('.') - 1
    while linenr > 0 do
        local line = vim.fn.getline(linenr)
        if line:match("%S") then
            return vim.fn.indent(linenr)
        end
        linenr = linenr - 1
    end
    return 0
end

local function get_next_non_empty_line_indent()
    local linenr = vim.fn.line('.') + 1
    local last_line = vim.fn.line("$")

    while linenr <= last_line do
        local line = vim.fn.getline(linenr)
        if line:match("%S") then
            return vim.fn.indent(linenr)
        end
        linenr = linenr + 1
    end
    return 0
end

local function custom_python_indent()
    local currline = vim.fn.getline(vim.fn.line('.'))
    local prevline = vim.fn.getline(vim.fn.line('.') - 1)
    local prevline_indent = vim.fn.indent(vim.fn.line('.') - 1)

    -- # Match indent for "in between" lines
    --
    -- example:
    -- ```
    -- def foo():
    --     a = 1
    -- |
    --     b = 2
    -- ```
    --
    -- `|` represents cursor, calling 'o' or 'O' will match indent of `a = 1` and `b = 2`.
    -- This needed because this "in between" lines are empty and have indent = 0, but they still belong to
    -- same function `foo` as `a = 1` and `b = 2` and should have same indent
    if currline == '' then
        local prevline_non_empty_indent = get_prev_non_empty_line_indent()
        local nextline_non_empty_indent = get_next_non_empty_line_indent()
        if prevline_non_empty_indent > 0 and nextline_non_empty_indent > 0 then
            -- math.min is here is for special cases
            -- ```
            -- def foo():
            --     def bar():
            --         a = 1
            -- |
            --     b = 2
            -- ```
            return math.min(prevline_non_empty_indent, nextline_non_empty_indent)
        end
    end

    -- # Increase indent
    --
    -- examples:
    -- ```
    -- if a == 2:|
    -- ```
    --
    -- ```
    -- arr = [|
    -- ```
    if prevline:match(":$") or prevline:match("{$") or prevline:match("%($") or prevline:match("%[$") then
        -- Except cases like this
        -- ```
        -- arr = [|]
        -- ```
        -- when you have closing bracket, calling <Enter> should not increase indent of line with single `]`
        if currline:match("%s}$") or currline:match("%s*%)$") or currline:match("%s*]$") then
            return -1
        end

        return prevline_indent + vim.bo.shiftwidth
    end

    -- # Decrease indent
    -- ```
    -- if a == 2:
    --     break|
    -- ```
    if prevline:match("^%s*pass") or prevline:match("^%s*return") or prevline:match("^%s*break") then
        return prevline_indent - vim.bo.shiftwidth
    end

    -- don't change indent
    return -1
end

-- Expose the function globally
_G.custom_python_indent = custom_python_indent

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.bo.indentexpr = "v:lua.custom_python_indent()"
        vim.bo.indentkeys = "0{,0},0),0],:,!^F,o,O,e,<:>,=elif,=except"
    end,
})


-- -- Automatically make the current string an f-string when typing `{`.
-- vim.api.nvim_create_autocmd("InsertCharPre", {
--     pattern = { "*.py" },
--     group = vim.api.nvim_create_augroup("py-fstring", { clear = true }),
--     callback = function(params)
--         if vim.v.char ~= "{" then return end
--
--         local node = vim.treesitter.get_node({})
--
--         if not node then return end
--
--         if node:type() ~= "string" then node = node:parent() end
--
--         if not node or node:type() ~= "string" then return end
--         local row, col, _, _ = vim.treesitter.get_node_range(node)
--         local first_char = vim.api.nvim_buf_get_text(params.buf, row, col, row, col + 1, {})[1]
--         if first_char == "f" or first_char == "r" then return end
--
--         vim.api.nvim_input("<Esc>m'" .. row + 1 .. "gg" .. col + 1 .. "|if<esc>`'la")
--     end,
-- })
