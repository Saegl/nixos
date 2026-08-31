-- Colorscheme picker.
--
-- Pick one below. Only that theme's plugin is installed: vim.pack.add fetches it
-- on the next start, so the other ~35 repos never touch disk. Plugins shipping a
-- bundle (catppuccin, nightfox, ...) get one entry per palette. A theme with no
-- `plugin` is vendored in colors/ and needs no download at all.

---@alias Theme
--- --- vendored in colors/, no plugin: github.com/if-not-nil/bark
---| 'bark'
--- --- datsfilipe/vesper.nvim
---| 'vesper'
--- --- yazeed1s/oh-lucy.nvim
---| 'oh-lucy'
---| 'oh-lucy-evening'
--- --- catppuccin/nvim
---| 'catppuccin-latte'
---| 'catppuccin-frappe'
---| 'catppuccin-macchiato'
---| 'catppuccin-mocha'
--- --- folke/tokyonight.nvim
---| 'tokyonight-night'
---| 'tokyonight-storm'
---| 'tokyonight-moon'
---| 'tokyonight-day'
--- --- rebelot/kanagawa.nvim
---| 'kanagawa-wave'
---| 'kanagawa-dragon'
---| 'kanagawa-lotus'
--- --- rose-pine/neovim
---| 'rose-pine-main'
---| 'rose-pine-moon'
---| 'rose-pine-dawn'
--- --- EdenEast/nightfox.nvim
---| 'nightfox'
---| 'duskfox'
---| 'nordfox'
---| 'terafox'
---| 'carbonfox'
---| 'dayfox'
---| 'dawnfox'
--- --- navarasu/onedark.nvim
---| 'onedark-dark'
---| 'onedark-darker'
---| 'onedark-cool'
---| 'onedark-deep'
---| 'onedark-warm'
---| 'onedark-warmer'
---| 'onedark-light'
--- --- olimorris/onedarkpro.nvim
---| 'onedarkpro'
---| 'onedarkpro-dark'
---| 'onedarkpro-vivid'
---| 'onedarkpro-vaporwave'
---| 'onedarkpro-light'
--- --- sainnhe/gruvbox-material
---| 'gruvbox-material-hard'
---| 'gruvbox-material-medium'
---| 'gruvbox-material-soft'
---| 'gruvbox-material-light'
--- --- ellisonleao/gruvbox.nvim
---| 'gruvbox'
---| 'gruvbox-hard'
---| 'gruvbox-soft'
---| 'gruvbox-light'
--- --- sainnhe/everforest
---| 'everforest-hard'
---| 'everforest-medium'
---| 'everforest-soft'
---| 'everforest-light'
--- --- projekt0n/github-nvim-theme
---| 'github_dark'
---| 'github_dark_default'
---| 'github_dark_dimmed'
---| 'github_dark_high_contrast'
---| 'github_light'
---| 'github_light_default'
---| 'github_light_high_contrast'
--- --- scottmckendry/cyberdream.nvim
---| 'cyberdream'
---| 'cyberdream-muted'
---| 'cyberdream-light'
--- --- Mofiqul/vscode.nvim
---| 'vscode-dark'
---| 'vscode-light'
--- --- Mofiqul/dracula.nvim
---| 'dracula'
---| 'dracula-soft'
--- --- nyoom-engineering/oxocarbon.nvim
---| 'oxocarbon'
---| 'oxocarbon-light'
--- --- marko-cerovac/material.nvim
---| 'material-darker'
---| 'material-oceanic'
---| 'material-palenight'
---| 'material-deep-ocean'
---| 'material-lighter'
--- --- shaunsingh/nord.nvim
---| 'nord'
--- --- AlexvZyl/nordic.nvim
---| 'nordic'
--- --- rmehri01/onenord.nvim
---| 'onenord'
---| 'onenord-light'
--- --- craftzdog/solarized-osaka.nvim
---| 'solarized-osaka'
---| 'solarized-osaka-vivid'
---| 'solarized-osaka-light'
--- --- sainnhe/sonokai
---| 'sonokai-default'
---| 'sonokai-atlantis'
---| 'sonokai-andromeda'
---| 'sonokai-shusia'
---| 'sonokai-maia'
---| 'sonokai-espresso'
--- --- sainnhe/edge
---| 'edge-default'
---| 'edge-aura'
---| 'edge-neon'
---| 'edge-light'
--- --- Shatur/neovim-ayu
---| 'ayu-dark'
---| 'ayu-mirage'
---| 'ayu-light'
--- --- bluz71/vim-moonfly-colors
---| 'moonfly'
--- --- bluz71/vim-nightfly-colors
---| 'nightfly'
--- --- tiagovla/tokyodark.nvim
---| 'tokyodark'
--- --- ribru17/bamboo.nvim
---| 'bamboo-vulgaris'
---| 'bamboo-multiplex'
---| 'bamboo-light'
--- --- savq/melange-nvim
---| 'melange'
---| 'melange-light'
--- --- slugbyte/lackluster.nvim
---| 'lackluster'
---| 'lackluster-hack'
---| 'lackluster-mint'
---| 'lackluster-dark'
---| 'lackluster-night'
--- --- vague-theme/vague.nvim
---| 'vague'
--- --- webhooked/kanso.nvim
---| 'kanso-zen'
---| 'kanso-ink'
---| 'kanso-mist'
---| 'kanso-pearl'
--- --- evergardentheme/nvim
---| 'evergarden-winter'
---| 'evergarden-spring'
---| 'evergarden-summer'
---| 'evergarden-fall'
--- --- wtfox/jellybeans.nvim
---| 'jellybeans'
---| 'jellybeans-mono'
---| 'jellybeans-muted'
---| 'jellybeans-warm'
---| 'jellybeans-light'

---@type Theme
local theme = 'bark'

---------- plugin sources
local sources = {
    ayu = 'https://github.com/Shatur/neovim-ayu',
    bamboo = 'https://github.com/ribru17/bamboo.nvim',
    catppuccin = 'https://github.com/catppuccin/nvim',
    cyberdream = 'https://github.com/scottmckendry/cyberdream.nvim',
    dracula = 'https://github.com/Mofiqul/dracula.nvim',
    edge = 'https://github.com/sainnhe/edge',
    evergarden = 'https://github.com/evergardentheme/nvim',
    everforest = 'https://github.com/sainnhe/everforest',
    ['github-theme'] = 'https://github.com/projekt0n/github-nvim-theme',
    gruvbox = 'https://github.com/ellisonleao/gruvbox.nvim',
    ['gruvbox-material'] = 'https://github.com/sainnhe/gruvbox-material',
    jellybeans = 'https://github.com/wtfox/jellybeans.nvim',
    kanagawa = 'https://github.com/rebelot/kanagawa.nvim',
    kanso = 'https://github.com/webhooked/kanso.nvim',
    lackluster = 'https://github.com/slugbyte/lackluster.nvim',
    material = 'https://github.com/marko-cerovac/material.nvim',
    melange = 'https://github.com/savq/melange-nvim',
    moonfly = 'https://github.com/bluz71/vim-moonfly-colors',
    nightfly = 'https://github.com/bluz71/vim-nightfly-colors',
    nightfox = 'https://github.com/EdenEast/nightfox.nvim',
    nord = 'https://github.com/shaunsingh/nord.nvim',
    nordic = 'https://github.com/AlexvZyl/nordic.nvim',
    ['oh-lucy'] = 'https://github.com/yazeed1s/oh-lucy.nvim',
    onedark = 'https://github.com/navarasu/onedark.nvim',
    onedarkpro = 'https://github.com/olimorris/onedarkpro.nvim',
    onenord = 'https://github.com/rmehri01/onenord.nvim',
    oxocarbon = 'https://github.com/nyoom-engineering/oxocarbon.nvim',
    ['rose-pine'] = 'https://github.com/rose-pine/neovim',
    ['solarized-osaka'] = 'https://github.com/craftzdog/solarized-osaka.nvim',
    sonokai = 'https://github.com/sainnhe/sonokai',
    tokyodark = 'https://github.com/tiagovla/tokyodark.nvim',
    tokyonight = 'https://github.com/folke/tokyonight.nvim',
    vague = 'https://github.com/vague-theme/vague.nvim',
    vesper = 'https://github.com/datsfilipe/vesper.nvim',
    vscode = 'https://github.com/Mofiqul/vscode.nvim',
}

---------- helpers for the 'before' hooks
-- Vimscript colorschemes take their options from globals set before ':colorscheme'.
local function globals(t)
    return function()
        for k, v in pairs(t) do vim.g[k] = v end
    end
end

-- Lua colorschemes with a single entry point take theirs from setup().
local function setup(module, opts)
    return function() require(module).setup(opts) end
end

-- Themes that pick their palette off 'background' rather than the colorscheme name.
local function light(before)
    return function()
        vim.o.background = 'light'
        if before then before() end
    end
end

---------- the themes
-- plugin:      key into `sources`
-- colorscheme: ':colorscheme' name, when it differs from the Theme key
-- before:      runs before ':colorscheme'
-- after:       runs after, for highlight overrides
---@type table<Theme, { plugin: string, colorscheme?: string, before?: fun(), after?: fun() }>
local themes = {
    -- upstream ships a bare bark.vim, not a plugin: vendored as colors/bark.vim
    bark = {
        after = function()
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
    },

    vesper = { plugin = 'vesper', before = setup('vesper', { transparent = false }) },

    ['oh-lucy'] = { plugin = 'oh-lucy' },
    ['oh-lucy-evening'] = {
        plugin = 'oh-lucy',
        -- Hey stranger, I use custom transparency because my terminal supports alpha, you probably need to remove this
        -- <custom-transparency>
        before = globals { oh_lucy_evening_transparent_background = true },
        after = function()
            local hl = vim.api.nvim_set_hl
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
        -- </custom-transparency>
    },

    ['catppuccin-latte'] = { plugin = 'catppuccin' },
    ['catppuccin-frappe'] = { plugin = 'catppuccin' },
    ['catppuccin-macchiato'] = { plugin = 'catppuccin' },
    ['catppuccin-mocha'] = { plugin = 'catppuccin' },

    ['tokyonight-night'] = { plugin = 'tokyonight' },
    ['tokyonight-storm'] = { plugin = 'tokyonight' },
    ['tokyonight-moon'] = { plugin = 'tokyonight' },
    ['tokyonight-day'] = { plugin = 'tokyonight' },

    ['kanagawa-wave'] = { plugin = 'kanagawa' },
    ['kanagawa-dragon'] = { plugin = 'kanagawa' },
    ['kanagawa-lotus'] = { plugin = 'kanagawa', before = light() },

    ['rose-pine-main'] = { plugin = 'rose-pine' },
    ['rose-pine-moon'] = { plugin = 'rose-pine' },
    ['rose-pine-dawn'] = { plugin = 'rose-pine' },

    nightfox = { plugin = 'nightfox' },
    duskfox = { plugin = 'nightfox' },
    nordfox = { plugin = 'nightfox' },
    terafox = { plugin = 'nightfox' },
    carbonfox = { plugin = 'nightfox' },
    dayfox = { plugin = 'nightfox' },
    dawnfox = { plugin = 'nightfox' },

    -- one colorscheme, seven palettes chosen in setup()
    ['onedark-dark'] = { plugin = 'onedark', colorscheme = 'onedark', before = setup('onedark', { style = 'dark' }) },
    ['onedark-darker'] = { plugin = 'onedark', colorscheme = 'onedark', before = setup('onedark', { style = 'darker' }) },
    ['onedark-cool'] = { plugin = 'onedark', colorscheme = 'onedark', before = setup('onedark', { style = 'cool' }) },
    ['onedark-deep'] = { plugin = 'onedark', colorscheme = 'onedark', before = setup('onedark', { style = 'deep' }) },
    ['onedark-warm'] = { plugin = 'onedark', colorscheme = 'onedark', before = setup('onedark', { style = 'warm' }) },
    ['onedark-warmer'] = { plugin = 'onedark', colorscheme = 'onedark', before = setup('onedark', { style = 'warmer' }) },
    ['onedark-light'] = { plugin = 'onedark', colorscheme = 'onedark', before = light(setup('onedark', { style = 'light' })) },

    onedarkpro = { plugin = 'onedarkpro', colorscheme = 'onedark' },
    ['onedarkpro-dark'] = { plugin = 'onedarkpro', colorscheme = 'onedark_dark' },
    ['onedarkpro-vivid'] = { plugin = 'onedarkpro', colorscheme = 'onedark_vivid' },
    ['onedarkpro-vaporwave'] = { plugin = 'onedarkpro', colorscheme = 'vaporwave' },
    ['onedarkpro-light'] = { plugin = 'onedarkpro', colorscheme = 'onelight', before = light() },

    ['gruvbox-material-hard'] = {
        plugin = 'gruvbox-material',
        colorscheme = 'gruvbox-material',
        before = globals { gruvbox_material_background = 'hard', gruvbox_material_better_performance = 1 },
    },
    ['gruvbox-material-medium'] = {
        plugin = 'gruvbox-material',
        colorscheme = 'gruvbox-material',
        before = globals { gruvbox_material_background = 'medium', gruvbox_material_better_performance = 1 },
    },
    ['gruvbox-material-soft'] = {
        plugin = 'gruvbox-material',
        colorscheme = 'gruvbox-material',
        before = globals { gruvbox_material_background = 'soft', gruvbox_material_better_performance = 1 },
    },
    ['gruvbox-material-light'] = {
        plugin = 'gruvbox-material',
        colorscheme = 'gruvbox-material',
        before = light(globals { gruvbox_material_background = 'medium', gruvbox_material_better_performance = 1 }),
    },

    gruvbox = { plugin = 'gruvbox' },
    ['gruvbox-hard'] = { plugin = 'gruvbox', colorscheme = 'gruvbox', before = setup('gruvbox', { contrast = 'hard' }) },
    ['gruvbox-soft'] = { plugin = 'gruvbox', colorscheme = 'gruvbox', before = setup('gruvbox', { contrast = 'soft' }) },
    ['gruvbox-light'] = { plugin = 'gruvbox', colorscheme = 'gruvbox', before = light() },

    ['everforest-hard'] = {
        plugin = 'everforest',
        colorscheme = 'everforest',
        before = globals { everforest_background = 'hard', everforest_better_performance = 1 },
    },
    ['everforest-medium'] = {
        plugin = 'everforest',
        colorscheme = 'everforest',
        before = globals { everforest_background = 'medium', everforest_better_performance = 1 },
    },
    ['everforest-soft'] = {
        plugin = 'everforest',
        colorscheme = 'everforest',
        before = globals { everforest_background = 'soft', everforest_better_performance = 1 },
    },
    ['everforest-light'] = {
        plugin = 'everforest',
        colorscheme = 'everforest',
        before = light(globals { everforest_background = 'medium', everforest_better_performance = 1 }),
    },

    github_dark = { plugin = 'github-theme' },
    github_dark_default = { plugin = 'github-theme' },
    github_dark_dimmed = { plugin = 'github-theme' },
    github_dark_high_contrast = { plugin = 'github-theme' },
    github_light = { plugin = 'github-theme' },
    github_light_default = { plugin = 'github-theme' },
    github_light_high_contrast = { plugin = 'github-theme' },

    cyberdream = { plugin = 'cyberdream' },
    ['cyberdream-muted'] = { plugin = 'cyberdream' },
    ['cyberdream-light'] = { plugin = 'cyberdream', before = light() },

    ['vscode-dark'] = { plugin = 'vscode', colorscheme = 'vscode' },
    ['vscode-light'] = { plugin = 'vscode', colorscheme = 'vscode', before = light() },

    dracula = { plugin = 'dracula' },
    ['dracula-soft'] = { plugin = 'dracula' },

    oxocarbon = { plugin = 'oxocarbon' },
    ['oxocarbon-light'] = { plugin = 'oxocarbon', colorscheme = 'oxocarbon', before = light() },

    ['material-darker'] = { plugin = 'material' },
    ['material-oceanic'] = { plugin = 'material' },
    ['material-palenight'] = { plugin = 'material' },
    ['material-deep-ocean'] = { plugin = 'material' },
    ['material-lighter'] = { plugin = 'material' },

    nord = { plugin = 'nord' },
    nordic = { plugin = 'nordic' },

    onenord = { plugin = 'onenord' },
    ['onenord-light'] = { plugin = 'onenord', before = light() },

    ['solarized-osaka'] = { plugin = 'solarized-osaka' },
    ['solarized-osaka-vivid'] = { plugin = 'solarized-osaka' },
    ['solarized-osaka-light'] = { plugin = 'solarized-osaka', before = light() },

    ['sonokai-default'] = {
        plugin = 'sonokai',
        colorscheme = 'sonokai',
        before = globals { sonokai_style = 'default', sonokai_better_performance = 1 },
    },
    ['sonokai-atlantis'] = {
        plugin = 'sonokai',
        colorscheme = 'sonokai',
        before = globals { sonokai_style = 'atlantis', sonokai_better_performance = 1 },
    },
    ['sonokai-andromeda'] = {
        plugin = 'sonokai',
        colorscheme = 'sonokai',
        before = globals { sonokai_style = 'andromeda', sonokai_better_performance = 1 },
    },
    ['sonokai-shusia'] = {
        plugin = 'sonokai',
        colorscheme = 'sonokai',
        before = globals { sonokai_style = 'shusia', sonokai_better_performance = 1 },
    },
    ['sonokai-maia'] = {
        plugin = 'sonokai',
        colorscheme = 'sonokai',
        before = globals { sonokai_style = 'maia', sonokai_better_performance = 1 },
    },
    ['sonokai-espresso'] = {
        plugin = 'sonokai',
        colorscheme = 'sonokai',
        before = globals { sonokai_style = 'espresso', sonokai_better_performance = 1 },
    },

    ['edge-default'] = {
        plugin = 'edge',
        colorscheme = 'edge',
        before = globals { edge_style = 'default', edge_better_performance = 1 },
    },
    ['edge-aura'] = {
        plugin = 'edge',
        colorscheme = 'edge',
        before = globals { edge_style = 'aura', edge_better_performance = 1 },
    },
    ['edge-neon'] = {
        plugin = 'edge',
        colorscheme = 'edge',
        before = globals { edge_style = 'neon', edge_better_performance = 1 },
    },
    ['edge-light'] = {
        plugin = 'edge',
        colorscheme = 'edge',
        before = light(globals { edge_style = 'default', edge_better_performance = 1 }),
    },

    ['ayu-dark'] = { plugin = 'ayu' },
    ['ayu-mirage'] = { plugin = 'ayu' },
    ['ayu-light'] = { plugin = 'ayu' },

    moonfly = { plugin = 'moonfly' },
    nightfly = { plugin = 'nightfly' },
    tokyodark = { plugin = 'tokyodark' },

    -- bamboo's colors/ files read a global that only setup() fills in
    ['bamboo-vulgaris'] = { plugin = 'bamboo', before = setup('bamboo', {}) },
    ['bamboo-multiplex'] = { plugin = 'bamboo', before = setup('bamboo', {}) },
    ['bamboo-light'] = { plugin = 'bamboo', before = setup('bamboo', {}) },

    melange = { plugin = 'melange' },
    ['melange-light'] = { plugin = 'melange', colorscheme = 'melange', before = light() },

    lackluster = { plugin = 'lackluster' },
    ['lackluster-hack'] = { plugin = 'lackluster' },
    ['lackluster-mint'] = { plugin = 'lackluster' },
    ['lackluster-dark'] = { plugin = 'lackluster' },
    ['lackluster-night'] = { plugin = 'lackluster' },

    vague = { plugin = 'vague' },

    ['kanso-zen'] = { plugin = 'kanso' },
    ['kanso-ink'] = { plugin = 'kanso' },
    ['kanso-mist'] = { plugin = 'kanso' },
    ['kanso-pearl'] = { plugin = 'kanso', before = light() },

    ['evergarden-winter'] = { plugin = 'evergarden' },
    ['evergarden-spring'] = { plugin = 'evergarden' },
    ['evergarden-summer'] = { plugin = 'evergarden' },
    ['evergarden-fall'] = { plugin = 'evergarden' },

    jellybeans = { plugin = 'jellybeans' },
    ['jellybeans-mono'] = { plugin = 'jellybeans' },
    ['jellybeans-muted'] = { plugin = 'jellybeans' },
    ['jellybeans-warm'] = { plugin = 'jellybeans' },
    ['jellybeans-light'] = { plugin = 'jellybeans', before = light() },
}

---------- load
local function load(name)
    local spec = themes[name]
    if not spec then
        vim.notify("theme: no such theme '" .. tostring(name) .. "'", vim.log.levels.ERROR)
        return
    end

    if spec.plugin then
        vim.pack.add { { src = sources[spec.plugin], name = spec.plugin } }
    end

    if spec.before then spec.before() end
    vim.cmd.colorscheme(spec.colorscheme or name)
    if spec.after then spec.after() end
end

load(theme)

---------- switcher
-- ':Theme' (or <leader>sC) picks from the list above, rewrites the `theme`
-- assignment in this file and restarts into it. Restarting rather than swapping
-- live because colorschemes leave each other's highlights behind, and the new
-- one may still need downloading.
local M = {}

local this_file = debug.getinfo(1, 'S').source:sub(2)
local session_file = vim.fs.joinpath(vim.fn.stdpath('state'), 'theme-restart.vim')

local names = vim.tbl_keys(themes)
table.sort(names)

---@param name Theme
function M.set(name)
    if not themes[name] then
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
    local installed = {}
    for _, p in ipairs(vim.pack.get()) do installed[p.spec.name] = true end

    local width = 0
    for _, name in ipairs(names) do width = math.max(width, #name) end

    local entries = vim.tbl_map(function(name)
        local plugin = themes[name].plugin
        local repo = plugin and sources[plugin]:gsub('^https://github%.com/', '')
            or ('colors/' .. name .. '.vim')
        local tag = name == theme and '  (current)'
            or (plugin and installed[plugin] and '  (downloaded)' or '')
        return ('%-' .. width .. 's  %s%s'):format(name, repo, tag)
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
