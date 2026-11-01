-- Convert a Neovim colorscheme into themes/<name>.toml and a colors/<name>.lua stub.
--
--   nvim -l scripts/theme2toml.lua <name> <source> [--colorscheme <cs>] [--before <lua>]
--
--   <name>        what the theme is called here: themes/<name>.toml, ':colorscheme <name>'
--   <source>      git URL (shallow-cloned to a temp dir) or a local plugin directory
--   --colorscheme upstream ':colorscheme' name, when it differs from <name>
--   --before      Lua run before ':colorscheme', for options: "require('x').setup { style = 'warm' }",
--                 "vim.g.foo_style = 'hard'", "vim.o.background = 'light'"
--
-- The theme runs in a clean, isolated Neovim; whatever it changes relative to Neovim's
-- defaults is written out, so it doesn't matter how the theme is implemented. The result is
-- then loaded back through lua/toml_theme.lua and compared group by group. See themes/README.md.

local script = vim.fs.normalize(vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p'))
local config = vim.fs.dirname(vim.fs.dirname(script))

---------- worker: runs inside 'nvim --clean', dumps the highlight state as JSON
local function load_all_syntaxes()
    local fts = {}
    for _, pat in ipairs { 'syntax/*.vim', 'syntax/*.lua' } do
        for _, f in ipairs(vim.api.nvim_get_runtime_file(pat, true)) do
            fts[vim.fn.fnamemodify(f, ':t:r')] = true
        end
    end
    for ft in vim.spairs(fts) do
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_call(buf, function() pcall(vim.cmd, 'silent! setlocal syntax=' .. ft) end)
        vim.api.nvim_buf_delete(buf, { force = true })
    end
end

local function dump()
    local groups = {}
    -- by name: listing them all can report a stale default link instead of what is set
    for name in pairs(vim.api.nvim_get_hl(0, {})) do
        local hl = vim.api.nvim_get_hl(0, { name = name })
        hl.cterm, hl.ctermfg, hl.ctermbg = nil, nil, nil -- only matter without 'termguicolors'
        for _, k in ipairs { 'fg', 'bg', 'sp' } do
            if hl[k] then hl[k] = ('#%06x'):format(hl[k]) end
        end
        groups[name] = hl
    end
    local terminal = {}
    for i = 0, 15 do
        local c = vim.g['terminal_color_' .. i]
        if c then terminal[tostring(i)] = c:lower() end
    end
    return { background = vim.o.background, groups = groups, terminal = terminal }
end

if _G.T2T_SPEC then
    local spec = vim.json.decode(_G.T2T_SPEC)
    vim.o.termguicolors = true
    local state
    if spec.mode == 'defaults' then
        -- syntax: every syntax file loaded; cleared: what a colorscheme starts from after 'hi clear'
        vim.o.background = spec.background
        local builtin = vim.tbl_keys(vim.api.nvim_get_hl(0, {}))
        load_all_syntaxes()
        local syntax = dump()
        vim.cmd('hi clear | syntax reset')
        vim.o.background = spec.background
        state = { builtin = builtin, syntax = syntax.groups, cleared = dump().groups }
    else
        -- like 'packadd': on 'runtimepath', plugin/ scripts sourced
        vim.opt.rtp:prepend(spec.rtp)
        if vim.uv.fs_stat(spec.rtp .. '/after') then vim.opt.rtp:append(spec.rtp .. '/after') end
        for _, f in ipairs(vim.fn.glob(spec.rtp .. '/plugin/**/*.{vim,lua}', false, true)) do
            vim.cmd.source(vim.fn.fnameescape(f))
        end
        -- Syntax files first, so the theme overrides any that set highlights outright. Then
        -- the theme's own after/syntax/ files, which some (sainnhe's) only fill in for it.
        load_all_syntaxes()
        if spec.before and spec.before ~= '' then assert(loadstring(spec.before, '--before'))() end
        vim.cmd.colorscheme(spec.colorscheme)
        for _, f in ipairs(vim.fn.glob(spec.rtp .. '/after/syntax/**/*.{vim,lua}', false, true)) do
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_call(buf, function() pcall(vim.cmd.source, vim.fn.fnameescape(f)) end)
            vim.api.nvim_buf_delete(buf, { force = true })
        end
        state = dump()
    end
    vim.fn.writefile({ vim.json.encode(state) }, spec.out)
    return
end

---------- driver
local function die(msg)
    io.stderr:write('theme2toml: ' .. msg .. '\n')
    os.exit(1)
end

local args, opts = {}, {}
do
    local i = 1
    while i <= #_G.arg do
        local a = _G.arg[i]
        if a == '--colorscheme' or a == '--before' then
            opts[a:sub(3)] = _G.arg[i + 1] or die(a .. ' needs a value')
            i = i + 1
        elseif a:match('^%-%-') then
            die('unknown option ' .. a)
        else
            args[#args + 1] = a
        end
        i = i + 1
    end
end
local name, source = args[1], args[2]
if not (name and source) then
    die('usage: nvim -l scripts/theme2toml.lua <name> <source> [--colorscheme <cs>] [--before <lua>]')
end
if not name:match('^[%w_.-]+$') then die('bad theme name: ' .. name) end

local tmp = vim.fn.tempname()
vim.fn.mkdir(tmp, 'p')

local function run(cmd, env)
    local r = vim.system(cmd, { text = true, env = env }):wait()
    if r.code ~= 0 then die(table.concat(cmd, ' ') .. '\n' .. (r.stderr or '') .. (r.stdout or '')) end
    return vim.trim(r.stdout or '')
end

-- Fresh nvim per capture, with XDG dirs in tmp: no user plugins, and themes that compile
-- to stdpath('cache') (catppuccin, nightfox, ...) neither read nor leave anything behind.
local xdg = {}
for _, d in ipairs { 'CONFIG', 'DATA', 'STATE', 'CACHE' } do
    xdg['XDG_' .. d .. '_HOME'] = tmp .. '/xdg/' .. d:lower()
end
local captures = 0
local function capture(spec)
    captures = captures + 1
    spec.out = ('%s/capture%d.json'):format(tmp, captures)
    run({
        'nvim', '--clean', '--headless',
        '--cmd', 'lua _G.T2T_SPEC = ' .. vim.inspect(vim.json.encode(spec)),
        '-c', 'luafile ' .. vim.fn.fnameescape(script), '-c', 'qa!',
    }, xdg)
    return vim.json.decode(table.concat(vim.fn.readfile(spec.out), '\n'))
end

-- source
local dir, url = source, source
if source:match('^https?://') or source:match('^git@') then
    dir = tmp .. '/src'
    run { 'git', 'clone', '--quiet', '--depth', '1', source, dir }
else
    dir = vim.fs.normalize(vim.fn.fnamemodify(source, ':p')):gsub('/$', '')
    if not vim.uv.fs_stat(dir) then die('no such directory: ' .. dir) end
    local r = vim.system({ 'git', '-C', dir, 'remote', 'get-url', 'origin' }, { text = true }):wait()
    url = r.code == 0 and vim.trim(r.stdout) or dir
end
local rev = vim.system({ 'git', '-C', dir, 'rev-parse', '--short', 'HEAD' }, { text = true }):wait()
rev = rev.code == 0 and vim.trim(rev.stdout) or nil
url = url:gsub('%.git$', '')

local colorscheme = opts.colorscheme or name
io.stderr:write(('theme2toml: %s <- %s %s\n'):format(name, url, colorscheme))
local theme = capture { mode = 'theme', rtp = dir, colorscheme = colorscheme, before = opts.before }
local defaults = capture { mode = 'defaults', background = theme.background }

---------- what the theme changed
-- Group names are case-insensitive, link targets too.
local function by_lower(groups)
    local t = {}
    for g, hl in pairs(groups) do t[g:lower()] = hl end
    return t
end
-- The 'default' flag isn't compared: 'hi def' keeps it, nvim_set_hl(.., { default = true })
-- doesn't, and it only says the group was set as a default.
local function same(a, b)
    a, b = vim.deepcopy(a or {}), vim.deepcopy(b or {})
    a.link, b.link = a.link and a.link:lower(), b.link and b.link:lower()
    a.default, b.default = nil, nil
    return vim.deep_equal(a, b)
end
local cleared, syntax = by_lower(defaults.cleared), by_lower(defaults.syntax)
-- A group still as a syntax file set it was left alone by a theme that doesn't 'hi clear';
-- the syntax file sets it again when its filetype is opened.
local function untouched(g, hl) return same(hl, cleared[g:lower()]) or same(hl, syntax[g:lower()]) end
local changed = {}
for g, hl in pairs(theme.groups) do
    if not untouched(g, hl) then changed[g] = hl end
end

---------- palette: name the colors after the source's own variables
local function set(list)
    local t = {}
    for _, v in ipairs(list) do t[v] = true end
    return t
end
local ATTR = set { 'fg', 'bg', 'sp', 'guifg', 'guibg', 'guisp', 'foreground', 'background',
    'color', 'link', 'style', 'default', 'none' }
local names, order = {}, {} -- hex -> { name -> count }, name/hex first-seen order
local function note(n, hex, line)
    hex = hex:lower()
    if #n < 2 or n:lower() == 'none' then return end
    -- 'fg = "#..."' is usually a highlight definition, not a palette entry
    if ATTR[n] and not line:match('^%s*["\']?[%w_.]+["\']?%s*[=:]%s*["\']#%x+["\']%s*,?%s*$') then return end
    names[hex] = names[hex] or {}
    if not names[hex][n] then order[#order + 1] = { n, hex } end
    names[hex][n] = (names[hex][n] or 0) + 1
end
for f, type in vim.fs.dir(dir, { depth = 10 }) do
    if type == 'file' and (f:match('%.lua$') or f:match('%.vim$') or f:match('%.json$'))
        and not f:match('^%.git/') and not f:match('^tests?/') and not f:match('^spec/') then
        local H = '["\'](#%x%x%x%x%x%x)["\']'
        for _, line in ipairs(vim.fn.readfile(dir .. '/' .. f)) do
            for _, pat in ipairs {
                '([%a_][%w_]*)%s*=%s*' .. H,                         -- red = "#..."    let s:red = '#...'
                '%[["\']([%a_][%w_]*)["\']%]%s*=%s*' .. H,           -- ["red"] = "#..."
                '["\']([%a_][%w_]*)["\']%s*:%s*%[?%s*' .. H,         -- 'red': ['#...', 1]   "red": "#..."
                '([%a_][%w_]*)%s*=%s*[%w_.:]+%(%s*' .. H,            -- red = Color.new("#...", ...)
                '([%a_][%w_]*)%s*=%s*{%s*' .. H,                     -- red = { "#...", ... }
                '([%a_][%w_]*)%s*=%s*{[^}]-default%s*=%s*' .. H,     -- red = { index = 1, default = "#..." }
            } do
                for n, hex in line:gmatch(pat) do note(n, hex, line) end
            end
        end
    end
end

local nvim_colors = {}
for n, v in vim.spairs(vim.api.nvim_get_color_map()) do -- sorted: 'Gray' over 'Grey', every run
    local hex = ('#%06x'):format(v)
    if n:match('^Nvim') and not nvim_colors[hex] then nvim_colors[hex] = n end
end

local used = {} -- hex -> times used
local function use(hex) used[hex] = (used[hex] or 0) + 1 end
for _, hl in pairs(changed) do
    for _, k in ipairs { 'fg', 'bg', 'sp' } do if hl[k] then use(hl[k]) end end
end
for _, c in pairs(theme.terminal) do if c:match('^#%x%x%x%x%x%x$') then use(c) end end

-- Most-used colors pick first, so the theme's own 'bg' gets the name rather than another
-- variant's 'bg' that turns up once. A color not in the source as-is but within 2 per channel
-- of one that is (rounding through HSL and back: catppuccin, nightfox) takes that name, with
-- its own value.
local by_use = vim.tbl_keys(used)
table.sort(by_use, function(a, b)
    if used[a] ~= used[b] then return used[a] > used[b] end
    return a < b
end)
local function rgb(hex) return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16) end
local function near(hex)
    local r, g, b = rgb(hex)
    local best, bd
    for src in vim.spairs(names) do
        local r2, g2, b2 = rgb(src)
        local d = math.max(math.abs(r - r2), math.abs(g - g2), math.abs(b - b2))
        if d <= 2 and (not bd or d < bd) then best, bd = src, d end
    end
    return best
end
local canon, taken = {}, {}
local function claim(hex, src)
    local cands = vim.tbl_keys(names[src] or {})
    table.sort(cands, function(a, b)
        if #a ~= #b then return #a < #b end
        if names[src][a] ~= names[src][b] then return names[src][a] > names[src][b] end
        return a < b
    end)
    for _, n in ipairs(cands) do
        if not taken[n] then
            canon[hex], taken[n] = n, hex
            return
        end
    end
end
for _, hex in ipairs(by_use) do claim(hex, hex) end
for _, hex in ipairs(by_use) do
    if not canon[hex] and not names[hex] then
        local src = near(hex)
        if src then claim(hex, src) end
    end
end
for hex in pairs(used) do canon[hex] = canon[hex] or nvim_colors[hex] or hex end

---------- sections
local SYNTAX = set(vim.split([[Comment Constant String Character Number Boolean Float
    Identifier Function Statement Conditional Repeat Label Operator Keyword Exception PreProc Include Define
    Macro PreCondit Type StorageClass Structure Typedef Special SpecialChar Tag Delimiter SpecialComment Debug
    Underlined Ignore Error Todo Added Changed Removed Bold Italic Variable]], '%s+', { trimempty = true }))
local PLUGINS = { -- group prefix -> plugin, first match wins
    { 'TSRainbow', 'nvim-ts-rainbow' }, { 'TS', 'nvim-treesitter, pre-0.8 TS* groups' },
    { 'Aerial', 'aerial.nvim' }, { 'Alpha', 'alpha-nvim' }, { 'ALE', 'ale' }, { 'Avante', 'avante.nvim' },
    { 'Barbecue', 'barbecue.nvim' }, { 'BlinkCmp', 'blink.cmp' }, { 'BlinkIndent', 'blink.indent' },
    { 'BufferLine', 'bufferline.nvim' }, { 'Buffer', 'barbar.nvim' }, { 'Bqf', 'nvim-bqf' },
    { 'Beacon', 'beacon.nvim' }, { 'Ccc', 'ccc.nvim' }, { 'Cmp', 'nvim-cmp' },
    { 'CodeActionMenu', 'nvim-code-action-menu' }, { 'Coc', 'coc.nvim' }, { 'Copilot', 'copilot' },
    { 'Dap', 'nvim-dap' }, { 'Dashboard', 'dashboard-nvim' }, { 'Diffview', 'diffview.nvim' },
    { 'DiffView', 'diffview.nvim' }, { 'Dropbar', 'dropbar.nvim' }, { 'Edgy', 'edgy.nvim' },
    { 'Fidget', 'fidget.nvim' }, { 'Flash', 'flash.nvim' }, { 'FlutterWidgetGuides', 'flutter-tools.nvim' },
    { 'Fzf', 'fzf-lua' }, { 'GitGutter', 'vim-gitgutter' }, { 'GitSigns', 'gitsigns.nvim' },
    { 'Glance', 'glance.nvim' }, { 'GrugFar', 'grug-far.nvim' }, { 'Harpoon', 'harpoon' },
    { 'Headline', 'headlines.nvim' }, { 'Helpview', 'helpview.nvim' }, { 'HlSearch', 'nvim-hlslens' },
    { 'Hop', 'hop.nvim' }, { 'Hydra', 'hydra.nvim' }, { 'Ibl', 'indent-blankline.nvim' },
    { 'IndentBlankline', 'indent-blankline.nvim' }, { 'IndentGuides', 'vim-indent-guides' },
    { 'Illuminated', 'vim-illuminate' }, { 'Lazy', 'lazy.nvim' }, { 'Leap', 'leap.nvim' },
    { 'Lightspeed', 'lightspeed.nvim' }, { 'LspSaga', 'lspsaga.nvim' }, { 'Saga', 'lspsaga.nvim' },
    { 'Finder', 'lspsaga.nvim' }, { 'Definition', 'lspsaga.nvim' }, { 'References', 'lspsaga.nvim' },
    { 'TargetFileName', 'lspsaga.nvim' }, { 'LSOutline', 'lspsaga.nvim' }, { 'Outline', 'lspsaga.nvim' },
    { 'Markview', 'markview.nvim' }, { 'Mason', 'mason.nvim' }, { 'MatchParenCur', 'vim-matchup' },
    { 'MatchWord', 'vim-matchup' }, { 'Mini', 'mini.nvim' }, { 'Navbuddy', 'nvim-navbuddy' },
    { 'Navic', 'nvim-navic' }, { 'NeoTree', 'neo-tree.nvim' }, { 'Neogit', 'neogit' },
    { 'Neotest', 'neotest' }, { 'NERDTree', 'nerdtree' }, { 'Noice', 'noice.nvim' },
    { 'Notify', 'nvim-notify' }, { 'NvimTree', 'nvim-tree.lua' }, { 'Octo', 'octo.nvim' },
    { 'Oil', 'oil.nvim' }, { 'Overseer', 'overseer.nvim' }, { 'Pounce', 'pounce.nvim' },
    { 'RainbowDelimiter', 'rainbow-delimiters.nvim' }, { 'RenderMarkdown', 'render-markdown.nvim' },
    { 'Sidekick', 'sidekick.nvim' }, { 'Snacks', 'snacks.nvim' }, { 'Sneak', 'vim-sneak' },
    { 'Startify', 'vim-startify' }, { 'Telescope', 'telescope.nvim' }, { 'TreesitterContext', 'nvim-treesitter-context' },
    { 'Trouble', 'trouble.nvim' }, { 'Ufo', 'nvim-ufo' }, { 'WhichKey', 'which-key.nvim' }, { 'Yanky', 'yanky.nvim' },
    { 'Vimwiki', 'vimwiki' }, { 'Signify', 'vim-signify' }, { 'Dirvish', 'vim-dirvish' }, { 'Fern', 'fern.vim' },
    { 'Clap', 'vim-clap' }, { 'Neomake', 'neomake' }, { 'Quickmenu', 'quickmenu.vim' }, { 'QuickScope', 'quick-scope' },
    { 'EasyMotion', 'vim-easymotion' }, { 'CtrlP', 'ctrlp.vim' }, { 'Glyph', 'glyph-palette.vim' },
    { 'Bookmark', 'vim-bookmarks' }, { 'Signature', 'vim-signature' }, { 'BufTabLine', 'buftabline' },
    { 'CursorWord', 'vim-cursorword' }, { 'CurrentWord', 'vim-current-word' }, { 'Rainbow', 'rainbow' }, { 'Scrollbar', 'nvim-scrollbar' },
}
local builtin = {}
for _, g in ipairs(defaults.builtin) do builtin[g:lower()] = true end

local link_targets = {}
for _, hl in pairs(changed) do
    if hl.link then link_targets[hl.link:lower()] = true end
end

local function section(g)
    if g:match('^@lsp') or g:match('^Lsp') then return 'LSP' end
    if g:match('^@') then return 'Treesitter' end
    if g:match('^Diagnostic') then return 'Diagnostics' end
    if SYNTAX[g] then return 'Syntax (:h group-name)' end
    if builtin[g:lower()] or g:match('^Toolbar') then return 'Editor UI' end -- Toolbar*: Vim's, not Nvim's
    for _, p in ipairs(PLUGINS) do
        if vim.startswith(g, p[1]) then return p[2] end
    end
    if syntax[g:lower()] or g:match('^%l') then return 'Filetype syntax' end
    if link_targets[g:lower()] then return 'Base groups (other groups link to them)' end
    return (g:match('^%u+%l*')) .. '*' -- unknown plugin: its leading word
end
local BUILTIN_SECTIONS = { 'Base groups (other groups link to them)', 'Editor UI', 'Syntax (:h group-name)', 'Treesitter', 'LSP', 'Diagnostics', 'Filetype syntax' }

---------- render
local function key(k) return k:match('^[%w_-]+$') and k or ('"%s"'):format(k) end
local function render(g, hl)
    if hl.link and vim.tbl_count(hl) == 1 then return ('%s = "%s"'):format(key(g), hl.link) end
    local parts = {}
    for _, k in ipairs { 'fg', 'bg', 'sp' } do
        if hl[k] then parts[#parts + 1] = ('%s = "%s"'):format(k, canon[hl[k]]) end
    end
    if hl.link then parts[#parts + 1] = ('link = "%s"'):format(hl.link) end
    if hl.blend then parts[#parts + 1] = ('blend = %d'):format(hl.blend) end
    for k, v in vim.spairs(hl) do
        if v == true then parts[#parts + 1] = k .. ' = true' end
    end
    if #parts == 0 then return key(g) .. ' = {}' end
    return ('%s = { %s }'):format(key(g), table.concat(parts, ', '))
end

local sections = {}
for g, hl in pairs(changed) do
    local s = section(g)
    sections[s] = sections[s] or {}
    table.insert(sections[s], { g:lower(), render(g, hl) })
end
-- a lone group from an unknown plugin isn't worth a section of its own
local other = {}
for s, items in pairs(sections) do
    if s:match('%*$') and #items == 1 then
        vim.list_extend(other, items)
        sections[s] = nil
    end
end
if #other > 0 then sections['Other'] = other end

local out = {
    ('# %s: generated by scripts/theme2toml.lua from %s%s'):format(name, url, rev and (' (rev ' .. rev .. ')') or ''),
    ("# as ':colorscheme %s'%s."):format(colorscheme, opts.before and (', with --before: ' .. opts.before:gsub('\n', ' ')) or ''),
    '# Group = { ... } sets attributes, Group = "Target" links. Colors are [palette] names, else as',
    "# nvim_set_hl takes them ('#rrggbb', 'NvimDarkRed'). Loaded by lua/toml_theme.lua.",
    '',
    ('name = "%s"'):format(name),
    ('source = "%s"'):format(url),
    ('background = "%s"'):format(theme.background),
    '',
    '[palette]',
}
local listed = {}
for _, nh in ipairs(order) do -- in source order
    local n = nh[1]
    if taken[n] and not listed[n] then
        listed[n] = true
        out[#out + 1] = ('%s = "%s"'):format(key(n), taken[n])
    end
end
if next(theme.terminal) then
    vim.list_extend(out, { '', '[terminal]' })
    for i = 0, 15 do
        local c = theme.terminal[tostring(i)]
        -- palette name or hex: g:terminal_color_N takes no 'NvimDarkRed'-style names
        if c then out[#out + 1] = ('%d = "%s"'):format(i, taken[canon[c]] == c and canon[c] or c) end
    end
end
vim.list_extend(out, { '', '[highlights]' })
local function emit(title, items)
    table.sort(items, function(a, b) return a[1] < b[1] end)
    vim.list_extend(out, { '', '# ' .. title })
    for _, it in ipairs(items) do out[#out + 1] = it[2] end
end
for _, s in ipairs(BUILTIN_SECTIONS) do
    if sections[s] then emit(s, sections[s]); sections[s] = nil end
end
if next(sections) then
    vim.list_extend(out, { '', '', '# ---------- Plugins' })
    local rest = vim.tbl_keys(sections)
    table.sort(rest, function(a, b)
        if (a == 'Other') ~= (b == 'Other') then return b == 'Other' end
        return a:lower() < b:lower()
    end)
    for _, s in ipairs(rest) do emit(s, sections[s]) end
end

local toml = ('%s/themes/%s.toml'):format(config, name)
vim.fn.mkdir(config .. '/themes', 'p')
vim.fn.writefile(out, toml)
vim.fn.writefile({ ("require('toml_theme').load('%s')"):format(name) }, ('%s/colors/%s.lua'):format(config, name))

---------- check: load the TOML back and compare with the original
local check = capture { mode = 'theme', rtp = config, colorscheme = name }
local problems = {}
if check.background ~= theme.background then
    problems[#problems + 1] = ('background: %s, original %s'):format(check.background, theme.background)
end
if not vim.deep_equal(check.terminal, theme.terminal) then problems[#problems + 1] = 'terminal colors differ' end
local got = by_lower(check.groups)
local seen = {}
for g, hl in pairs(theme.groups) do
    local c = got[g:lower()]
    seen[g:lower()] = true
    -- a group the theme left as a syntax file set it comes back cleared, as after any 'hi clear'
    if not same(c, hl) and not (untouched(g, hl) and same(c, cleared[g:lower()])) then
        problems[#problems + 1] = ('%s: %s, original %s'):format(g, vim.inspect(c or {}, { newline = '' }),
            vim.inspect(hl, { newline = '' }))
    end
end
for g, hl in pairs(check.groups) do
    if not seen[g:lower()] and next(hl) then problems[#problems + 1] = g .. ': set, original empty' end
end

vim.fn.delete(tmp, 'rf')
local rel = vim.fn.fnamemodify(toml, ':~:.')
if #problems > 0 then
    table.sort(problems)
    die(('%s written, but %d group(s) differ from the original:\n  %s'):format(rel, #problems,
        table.concat(vim.list_slice(problems, 1, 20), '\n  ')))
end
print(('%s: %d groups, identical to the original'):format(rel, vim.tbl_count(changed)))
