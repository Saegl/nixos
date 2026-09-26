-- Show the function under cursor annotated with values recorded by iotrace/iotrace.py during pytest
local M = {}

local ns = vim.api.nvim_create_namespace('iotrace')
vim.api.nvim_set_hl(0, 'IotraceDead', { default = true, link = 'NonText' })
vim.api.nvim_set_hl(0, 'IotraceValue', { default = true, link = 'DiagnosticHint' })
vim.api.nvim_set_hl(0, 'IotraceReturn', { default = true, link = 'DiagnosticOk' })
vim.api.nvim_set_hl(0, 'IotraceRaise', { default = true, link = 'DiagnosticError' })

local MAX_INLINE = 80
-- Annotations of a line longer than this (or multi-line) go below it when expanded
local INLINE_BUDGET = 100

local cache = { path = nil, mtime = 0, data = nil }

local function load(path)
    local stat = vim.uv.fs_stat(path)
    if not stat then return nil end
    if cache.path ~= path or cache.mtime ~= stat.mtime.sec then
        local f = assert(io.open(path, 'r'))
        cache.data = vim.json.decode(f:read('*a'))
        f:close()
        cache.path, cache.mtime = path, stat.mtime.sec
    end
    return cache.data
end

-- Returns function name and its co_firstlineno (first decorator line, if decorated)
local function function_at_cursor()
    local node = vim.treesitter.get_node()
    while node and node:type() ~= 'function_definition' do
        node = node:parent()
    end
    if not node then return nil end
    local name = vim.treesitter.get_node_text(node:field('name')[1], 0)
    local outer = node:parent()
    if outer and outer:type() == 'decorated_definition' then node = outer end
    return name, node:start() + 1
end

local function find(data, file, name, line)
    local exact = data[file .. ':' .. line]
    if exact then return exact end
    -- File was edited since the run: fall back to the same-named function nearest to the cursor
    local best, best_dist
    for _, fn in pairs(data) do
        if fn.file == file and fn.name:match('([^.]+)$') == name then
            local dist = math.abs(fn.line - line)
            if not best or dist < best_dist then best, best_dist = fn, dist end
        end
    end
    return best
end

local function inline(value)
    local s = value:gsub('%s*\n%s*', ' ')
    if vim.fn.strchars(s) > MAX_INLINE then s = vim.fn.strcharpart(s, 0, MAX_INLINE) .. '…' end
    return s
end

-- Annotations per absolute line: list of { label, value, hl }
local function annotations(fn, call)
    local notes = {}
    local function add(line, label, value, hl)
        notes[line] = notes[line] or {}
        table.insert(notes[line], { label = label, value = value, hl = hl })
    end
    for _, arg in ipairs(call.args) do add(fn.def_line, arg[1] .. ' = ', arg[2], 'IotraceValue') end
    for key, entry in pairs(call.lines) do
        local line = tonumber(key)
        for _, val in ipairs(entry.vals or {}) do add(line, val[1] .. ' = ', val[2], 'IotraceValue') end
        for _, value in ipairs(entry.yields or {}) do add(line, 'yield ', value, 'IotraceReturn') end
        if entry['return'] and line ~= fn.def_line then add(line, '→ ', entry['return'], 'IotraceReturn') end
        if entry['raise'] then add(line, '✗ ', entry['raise'], 'IotraceRaise') end
    end
    return notes
end

local function eol_chunks(notes, hits, compact_values)
    local chunks = {}
    if compact_values then
        for _, note in ipairs(notes) do
            table.insert(chunks, { '  ' })
            table.insert(chunks, { note.label .. inline(note.value), note.hl })
        end
    end
    if hits > 1 then table.insert(chunks, { '  ×' .. hits, 'Comment' }) end
    return chunks
end

local function block_lines(notes, indent)
    local virt = {}
    for _, note in ipairs(notes) do
        local parts = vim.split(note.value, '\n', { plain = true })
        local pad = string.rep(' ', vim.fn.strdisplaywidth(note.label))
        for i, part in ipairs(parts) do
            local text = (i == 1 and note.label or pad) .. part
            table.insert(virt, { { indent .. '│ ', 'Comment' }, { text, note.hl } })
        end
    end
    return virt
end

local function fits_inline(notes)
    local len = 0
    for _, note in ipairs(notes) do
        if note.value:find('\n') then return false end
        len = len + #note.label + #note.value + 2
    end
    return len <= INLINE_BUDGET
end

local function render(state)
    local fn, call = state.fn, state.fn.calls[state.idx]
    local buf = state.buf
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    local nlines = vim.api.nvim_buf_line_count(buf)
    for _, line in ipairs(call.dead or {}) do
        local row = line - fn.line
        if row >= 0 and row < nlines then
            vim.api.nvim_buf_set_extmark(buf, ns, row, 0, { line_hl_group = 'IotraceDead', priority = 200 })
        end
    end
    state.notes = annotations(fn, call)
    local nvirt = 0
    for row = 0, nlines - 1 do
        local line = row + fn.line
        local notes = state.notes[line] or {}
        local entry = call.lines[tostring(line)] or {}
        local compact = not state.expanded or fits_inline(notes)
        local opts = { virt_text = eol_chunks(notes, entry.hits or 0, compact), hl_mode = 'combine' }
        if not compact then
            local src = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
            opts.virt_lines = block_lines(notes, src:match('^%s*') .. '    ')
            nvirt = nvirt + #opts.virt_lines
        end
        if #opts.virt_text > 0 or opts.virt_lines then vim.api.nvim_buf_set_extmark(buf, ns, row, 0, opts) end
    end
    local status = call['raise'] and 'raised' or (call['return'] and 'returned' or 'unfinished')
    local height = math.min(nlines + nvirt, math.floor(vim.o.lines * 0.75))
    vim.api.nvim_win_set_config(state.win, {
        relative = 'editor', height = height,
        row = math.floor((vim.o.lines - height) / 2) - 1, col = state.col,
        title = (' %s · call %d/%d · %s '):format(fn.name, state.idx, #fn.calls, status),
        footer = (' %s · <Tab>/<S-Tab> call · e expand · K value · gt test · q close '):format(call.test or '<outside test>'),
    })
end

-- Full (multi-line) values annotated on the cursor line
local function show_value(state)
    local line = vim.api.nvim_win_get_cursor(state.win)[1] + state.fn.line - 1
    local notes = state.notes[line]
    if not notes then return end
    local lines = {}
    for _, note in ipairs(notes) do
        local parts = vim.split(note.value, '\n', { plain = true })
        table.insert(lines, note.label .. parts[1])
        local indent = string.rep(' ', vim.fn.strdisplaywidth(note.label))
        for i = 2, #parts do table.insert(lines, indent .. parts[i]) end
    end
    vim.lsp.util.open_floating_preview(lines, 'python', { focus_id = 'iotrace_value' })
end

local function open(fn, cursor_line, root)
    local lines = vim.split(fn.source:gsub('\n$', ''), '\n', { plain = true })
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = 'python'
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = 'wipe'
    local width = math.floor(vim.o.columns * 0.85)
    local col = math.floor((vim.o.columns - width) / 2)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor', style = 'minimal', width = width, height = 1, row = 0, col = col,
        title = ' ', footer = ' ',
    })
    vim.wo[win].wrap = false
    vim.wo[win].number = true
    vim.wo[win].cursorline = true
    vim.api.nvim_win_set_cursor(win, { math.max(1, math.min(cursor_line - fn.line + 1, #lines)), 0 })

    local state = { fn = fn, idx = 1, buf = buf, win = win, col = col, expanded = true, root = root }
    render(state)
    local function map(key, f) vim.keymap.set('n', key, f, { buffer = buf, nowait = true }) end
    local function step(d)
        return function()
            state.idx = (state.idx - 1 + d) % #fn.calls + 1
            render(state)
        end
    end
    map('<Tab>', step(1))
    map('<S-Tab>', step(-1))
    map('K', function() show_value(state) end)
    map('e', function()
        state.expanded = not state.expanded
        render(state)
    end)
    map('gt', function()
        local call = fn.calls[state.idx]
        -- Old data has no test_loc: take the file from the nodeid
        local loc = call.test_loc or (call.test and { call.test:match('^[^:]+'), 1 })
        if not loc then return end
        vim.api.nvim_win_close(win, true)
        vim.cmd.edit(vim.fn.fnameescape(state.root .. '/' .. loc[1]))
        vim.api.nvim_win_set_cursor(0, { loc[2], 0 })
        vim.cmd('normal! zz')
    end)
    map('q', '<cmd>close<cr>')
    map('<Esc>', '<cmd>close<cr>')
end

function M.show()
    local root = vim.fs.root(0, '.pytest_cache')
    local data = root and load(root .. '/.pytest_cache/iotrace.json')
    if not data then
        vim.notify('iotrace: no data, run PYTHONPATH=~/.config/nvim/iotrace pytest -p iotrace', vim.log.levels.WARN)
        return
    end
    local name, line = function_at_cursor()
    if not name then
        vim.notify('iotrace: cursor is not inside a function', vim.log.levels.WARN)
        return
    end
    local file = vim.fs.relpath(root, vim.api.nvim_buf_get_name(0))
    local fn = file and find(data, file, name, line)
    if not fn or not fn.source then
        vim.notify(('iotrace: no calls recorded for %s'):format(name), vim.log.levels.WARN)
        return
    end
    open(fn, vim.fn.line('.'), root)
end

return M
