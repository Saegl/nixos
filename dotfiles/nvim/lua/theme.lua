-- Colorscheme picker.
--
-- Every theme is plain data: themes/<name>.toml, applied by lua/toml_theme.lua through
-- a colors/<name>.lua stub, so ':colorscheme <name>' works too. Nothing is downloaded;
-- to add a theme, convert it from its plugin with scripts/theme2toml.lua, see
-- themes/README.md.

---@type string a themes/<name>.toml
local theme = 'oh-lucy'

---------- overrides
-- Your own tweaks on top of a theme, run after it loads.
local overrides = {
    bark = function()
        -- One colour for every keyword. Left alone, 'import'/'from' fall
        -- through to Include and bark paints @keyword.return (which also
        -- covers 'yield') red, so both drift off the purple 'class'/'def'
        -- and the rest of the family already sit on.
        for _, group in ipairs { '@keyword.import', '@keyword.return' } do
            vim.api.nvim_set_hl(0, group, { link = '@keyword' })
        end

        -- ... which leaves 'import sys' all one colour, since base16 maps
        -- @module -> Structure onto Keyword's purple too. Modules go to the
        -- plain foreground instead: @module only fires inside the import
        -- statement, and 'sys' is already @variable everywhere it is used.
        vim.api.nvim_set_hl(0, '@module', { link = '@variable' })

        -- Decorators land on @attribute -> Macro, bark's error red. They
        -- read as the function they are: '@dataclass' like 'def blue()'.
        vim.api.nvim_set_hl(0, '@attribute', { link = '@function' })
    end,

    ['oh-lucy-evening'] = function()
        -- Hey stranger, I use custom transparency because my terminal supports alpha, you probably need to remove this
        local hl = vim.api.nvim_set_hl

        -- What upstream's g:oh_lucy_evening_transparent_background did. The vimdoc
        -- heading rules were drawn in Normal's bg, so without one they have no colour.
        for _, g in ipairs({ 'Normal', 'NormalNC', 'MsgArea', 'TelescopeBorder',
            '@markup.heading.1.delimiter.vimdoc', '@markup.heading.2.delimiter.vimdoc' }) do
            local cur = vim.api.nvim_get_hl(0, { name = g, link = false })
            if g:match('vimdoc$') then cur.fg = nil end
            cur.bg = nil
            hl(0, g, cur)
        end

        for _, g in ipairs({
            'SignColumn', 'LineNr', 'CursorLineNr', 'FoldColumn',
            'GitSignsAdd', 'GitSignsChange', 'GitSignsDelete',
            'DiagnosticSignError', 'DiagnosticSignWarn', 'DiagnosticSignInfo', 'DiagnosticSignHint',
            'TabLineFill', 'BufferLineFill', 'BufferLineBackground',
            'BufferLineTab', 'BufferLineTabClose',
            'BufferLineSeparator', 'BufferLineTabSeparator', 'BufferLineOffsetSeparator',
        }) do hl(0, g, { bg = 'NONE' }) end

        for _, g in ipairs({
            'BufferLineBufferVisible', 'BufferLineCloseButton', 'BufferLineCloseButtonVisible',
            'BufferLineModified', 'BufferLineModifiedVisible', 'BufferLineGroupLabel',
        }) do
            local cur = vim.api.nvim_get_hl(0, { name = g, link = false })
            cur.bg = 'NONE'
            hl(0, g, cur)
        end

        hl(0, 'BufferLineDuplicate', { bg = 'NONE', fg = '#685D69', italic = true })
        hl(0, 'BufferLineDuplicateVisible', { bg = 'NONE', fg = '#685D69', italic = true })
        hl(0, 'BufferLineDuplicateSelected', { bg = 'NONE', fg = '#9B8F91', italic = true })
        hl(0, 'BufferLineNumbersSelected', { bg = 'NONE', fg = '#DECED0', italic = false, bold = false })
        hl(0, 'BufferLineNumbersVisible', { bg = 'NONE', fg = '#9B8F91', italic = false, bold = false })

        hl(0, 'LineNr', { bg = 'NONE', fg = '#524551' })
        hl(0, 'CursorLineNr', { bg = 'NONE', fg = '#9B8F91' })
        hl(0, 'WinSeparator', { bg = 'NONE', fg = 'NONE' })
        hl(0, 'PmenuSel', { bg = '#282933' })
        hl(0, 'Visual', { bg = '#3b4252' })
    end,
}

---------- load
-- name -> path of its themes/<name>.toml
local sources = {}
for _, path in ipairs(vim.api.nvim_get_runtime_file('themes/*.toml', true)) do
    local name = vim.fn.fnamemodify(path, ':t:r')
    sources[name] = sources[name] or path
end

local function load(name)
    if not sources[name] then
        vim.notify("theme: no such theme '" .. tostring(name) .. "'", vim.log.levels.ERROR)
        return
    end
    vim.cmd.colorscheme(name)
    if overrides[name] then overrides[name]() end
end

load(theme)

---------- switcher
-- ':Theme' (or <leader>sC) picks from themes/, rewrites the `theme` assignment in
-- this file and restarts into it. Restarting rather than swapping live because
-- overrides and plugins that derive colors at startup leave the old theme behind.
local M = {}

local this_file = debug.getinfo(1, 'S').source:sub(2)
local session_file = vim.fs.joinpath(vim.fn.stdpath('state'), 'theme-restart.vim')

local names = vim.tbl_keys(sources)
table.sort(names)

---@param name string
function M.set(name)
    if not sources[name] then
        vim.notify("theme: no such theme '" .. tostring(name) .. "'", vim.log.levels.ERROR)
        return
    end

    local lines = vim.fn.readfile(this_file)
    local at
    for i, line in ipairs(lines) do
        if line:match("^local theme = '") then at = i break end
    end
    if not at then
        vim.notify('theme: no `local theme` assignment in ' .. this_file, vim.log.levels.ERROR)
        return
    end
    lines[at] = ("local theme = '%s'"):format(name)
    if vim.fn.writefile(lines, this_file) ~= 0 then
        vim.notify('theme: could not write ' .. this_file, vim.log.levels.ERROR)
        return
    end

    -- ':restart' reuses v:argv minus its files, so the buffer list would be lost
    local sessionoptions = vim.o.sessionoptions
    vim.o.sessionoptions = 'blank,buffers,curdir,folds,tabpages,winsize'
    vim.fn.mkdir(vim.fs.dirname(session_file), 'p')
    local stashed = pcall(vim.cmd, 'mksession! ' .. vim.fn.fnameescape(session_file))
    vim.o.sessionoptions = sessionoptions
    if not stashed then
        vim.notify('theme: no session stashed, buffers will not come back', vim.log.levels.WARN)
    end

    vim.cmd('restart lua require("theme").restore()')
end

-- Runs on the instance ':restart' brings up, see M.set
function M.restore()
    if vim.uv.fs_stat(session_file) then
        vim.cmd('silent! source ' .. vim.fn.fnameescape(session_file))
        vim.fn.delete(session_file)
    end
end

function M.pick()
    local width = 0
    for _, name in ipairs(names) do width = math.max(width, #name) end

    local entries = vim.tbl_map(function(name)
        -- `source = "..."` sits in the first lines of each file
        local upstream = ''
        for _, line in ipairs(vim.fn.readfile(sources[name], '', 10)) do
            upstream = line:match('^source = "https://github%.com/(.*)"$') or line:match('^source = "(.*)"$') or upstream
        end
        local tag = name == theme and '  (current)' or ''
        return ('%-' .. width .. 's  %s%s'):format(name, upstream, tag)
    end, names)

    require('fzf-lua').fzf_exec(entries, {
        prompt = 'Theme> ',
        actions = {
            -- deferred: ':restart' quits, let fzf tear its window down first
            default = function(selected)
                if selected and selected[1] then
                    local name = selected[1]:match('^%S+')
                    vim.schedule(function() M.set(name) end)
                end
            end,
        },
    })
end

vim.api.nvim_create_user_command('Theme', function(opts)
    if opts.args == '' then M.pick() else M.set(opts.args) end
end, {
    nargs = '?',
    complete = function(lead)
        return vim.tbl_filter(function(name) return vim.startswith(name, lead) end, names)
    end,
    desc = 'Switch colorscheme (restarts nvim)',
})

vim.keymap.set('n', '<leader>sC', M.pick, { desc = 'Colorscheme' })

return M
