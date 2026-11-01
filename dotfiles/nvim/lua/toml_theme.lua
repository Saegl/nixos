-- Colorschemes as data: themes/<name>.toml, applied by a colors/<name>.lua stub. Not kept in
-- colors/ because ':colorscheme' sources any colors/<name>.*, .toml included.
--
--   name = "x"  source = "url"  background = "dark"
--   [palette]     color = "#rrggbb"
--   [terminal]    0 = "color" ... 15 = "color"   (g:terminal_color_N)
--   [highlights]  Group = { fg = "color", bg = ..., sp = ..., bold = true, blend = 80, ... }
--                 Group = "Target"   (link)
--
-- Colors are palette names, else passed to nvim_set_hl as-is ('#rrggbb', 'NvimDarkRed', 'bg').

local M = {}

-- TOML subset: comments, [tables], and key = string | integer | bool | flat { inline table }.
local function parse(text, path)
    local root = {}
    local cur = root

    local function key(s)
        local k, rest = s:match('^"([^"]*)"%s*(.*)')
        if not k then k, rest = s:match('^([%w_-]+)%s*(.*)') end
        return k, rest
    end

    local function value(s)
        local str, rest = s:match('^"([^"]*)"%s*(.*)')
        if str then return str, rest end
        local word, rest2 = s:match('^([%w_-]+)%s*(.*)')
        if word == 'true' or word == 'false' then return word == 'true', rest2 end
        if word and tonumber(word) then return tonumber(word), rest2 end
    end

    for lnum, line in ipairs(vim.split(text, '\n')) do
        local s = vim.trim(line:gsub('%s#.*$', ''):gsub('^#.*$', ''))
        local function fail() error(('%s:%d: cannot parse: %s'):format(path, lnum, line), 0) end
        if s == '' then
        elseif s:match('^%[') then
            local t = s:match('^%[([%w_-]+)%]$') or fail()
            root[t] = root[t] or {}
            cur = root[t]
        else
            local k, rest = key(s)
            if not k then fail() end
            rest = rest:match('^=%s*(.*)') or fail()
            if rest:match('^{') then
                local tbl, body = {}, rest:match('^{(.*)}$') or fail()
                for item in vim.gsplit(body, ',') do
                    if vim.trim(item) ~= '' then
                        local ik, irest = key(vim.trim(item))
                        local v = ik and value(irest:match('^=%s*(.*)') or '')
                        if v == nil then fail() end
                        tbl[ik] = v
                    end
                end
                cur[k] = tbl
            else
                local v, tail = value(rest)
                if v == nil or tail ~= '' then fail() end
                cur[k] = v
            end
        end
    end
    return root
end

function M.load(name)
    local path = vim.api.nvim_get_runtime_file(('themes/%s.toml'):format(name), false)[1]
        or error(('toml_theme: themes/%s.toml not found'):format(name))
    local theme = parse(table.concat(vim.fn.readfile(path), '\n'), path)
    local palette = theme.palette or {}
    local function color(c) return palette[c] or c end

    vim.cmd.highlight('clear')
    if vim.g.syntax_on then vim.cmd.syntax('reset') end
    if theme.background then vim.o.background = theme.background end
    vim.g.colors_name = theme.name or name

    for group, spec in pairs(theme.highlights or {}) do
        if type(spec) == 'string' then
            spec = { link = spec }
        else
            for _, attr in ipairs { 'fg', 'bg', 'sp' } do
                if spec[attr] then spec[attr] = color(spec[attr]) end
            end
        end
        vim.api.nvim_set_hl(0, group, spec)
    end

    local terminal = theme.terminal or {}
    for i = 0, 15 do
        local c = terminal[tostring(i)]
        vim.g['terminal_color_' .. i] = c and color(c) or nil
    end
end

return M
