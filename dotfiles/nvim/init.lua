-- TOC:
-- 1_PLUGINS_LIST
-- 2_OPTIONS
-- 3_KEYMAPS
-- 4_PICKER
-- 5_FILES
-- 6_TERMINAL
-- 7_TREESITTER
-- 8_LSP
-- 9_DAP
-- 10_TABS
-- 11_GIT
-- 12_FORMATTER
-- 13_EXTRA

---------- 1_PLUGINS_LIST
vim.pack.add {
    -- picker
    'https://github.com/ibhagwan/fzf-lua',
    -- lsp
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/j-hui/fidget.nvim',
    -- main is v2: unstable, needs the new 'blink.lib' dep; stay on the v1 line
    { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
    -- treesitter
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/Wansmer/treesj',
    -- icons
    'https://github.com/nvim-tree/nvim-web-devicons',
    -- dap
    'https://github.com/mfussenegger/nvim-dap',
    'https://github.com/rcarriga/nvim-dap-ui',
    'https://github.com/nvim-neotest/nvim-nio',
    'https://github.com/theHamsta/nvim-dap-virtual-text',
    -- git
    'https://github.com/NeogitOrg/neogit',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/sindrets/diffview.nvim',
    'https://github.com/lewis6991/gitsigns.nvim',
    -- dial
    'https://github.com/monaqa/dial.nvim',
    -- undotree
    'https://github.com/mbbill/undotree',
    -- misc
    'https://github.com/akinsho/bufferline.nvim',
    'https://github.com/tpope/vim-sleuth',
    'https://github.com/folke/which-key.nvim',
    'https://github.com/echasnovski/mini.files',
    'https://github.com/akinsho/toggleterm.nvim',
    'https://github.com/kevinhwang91/nvim-hlslens',
    -- colorschemes are installed on demand, see lua/theme.lua
}

vim.api.nvim_create_user_command('PackUpdate', function() vim.pack.update() end, {})
vim.api.nvim_create_user_command('PackDel', function(opts) vim.pack.del({ opts.args }) end, { nargs = 1 })
-- Check out every plugin at its lockfile revision: reverts a bad update, or matches another machine
vim.api.nvim_create_user_command('PackSync', function() vim.pack.update(nil, { target = 'lockfile' }) end, {})

---------- 2_OPTIONS
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.relativenumber = true

-- Turn '~' into operator ('~' is swapcase action)
vim.o.tildeop = true

-- Enable mouse in all modes, in 'nvi' by default
vim.o.mouse = 'a'

vim.o.winborder = "rounded"

-- Remove this duplicate '--INSERT--' on last line, when going to insert mode
vim.o.laststatus = 0
vim.o.ruler = false
vim.o.showmode = false
vim.o.showcmd = false
vim.o.undofile = true

-- Preserve indentation on wrapped (long lines)
vim.o.breakindent = true
vim.o.showbreak = '>>'

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true -- ignore case in search
vim.o.smartcase = true  -- ignore 'ignore' if pattern contains uppercase letters

-- Hide builtin "[1/345]" search count on the bottom line, hlslens shows it inline
vim.opt.shortmess:append('S')

-- always draw leftest column for signs (git, breakpoints etc)
vim.o.signcolumn = 'yes'

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.o.timeoutlen = 300

-- Nice exit
vim.o.confirm = true

-- print debugging going wild
vim.o.scrollback = 20000

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Wrap <Left> <Right>, in normal mode (<,>) and insert mode ([,])
vim.opt.whichwrap = "b,s,<,>,[,],h,l"

-- Preview substitutions
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = false

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 5

vim.o.tabstop = 4      -- <Tab> size
vim.o.shiftwidth = 4   -- Number of spaces for (auto)indent
vim.o.expandtab = true -- Substitute <Tab> with spaces

-- Colorscheme, ':Theme' or <leader>sC to switch, see lua/theme.lua
require('theme')

---------- 3_KEYMAPS
-- Move lines up and down in visual selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Window resize (<M-h>/<M-l> live with the terminal cycle, see 6_TERMINAL)
vim.keymap.set("n", "<M-j>", "<C-w>-")
vim.keymap.set("n", "<M-k>", "<C-w>+")

-- Horizontal movement
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- System clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })
vim.keymap.set('n', '<leader>l', function()
    local path = vim.fn.expand('%')
    vim.fn.setreg('+', path)
    vim.notify('Copied: ' .. path)
end, { desc = "Copy buffer path to clipboard" })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.o.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Regular editor behavior
-- Normal mode only: insert-mode <C-s> stays nvim's builtin signature help (:h lsp-defaults)
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>', { desc = "save" })
vim.keymap.set({ 'n', 'v' }, '<C-a>', '<C-\\><C-n>ggVG', { desc = "select all" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})

---------- 4_PICKER
local fzf = require('fzf-lua')
fzf.setup()

vim.keymap.set("n", "<leader>sf", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>sG", function()
    vim.ui.input({ prompt = "Grep in dir: ", completion = "dir" }, function(dir)
        if dir and dir ~= "" then
            fzf.live_grep({ cwd = vim.fn.expand(dir) })
        end
    end)
end, { desc = "Live grep in dir" })
vim.keymap.set("n", "<leader>sb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "Help tags" })
vim.keymap.set("n", "<leader>sr", fzf.resume, { desc = "Resume last picker" })
vim.keymap.set("n", "<leader>so", fzf.oldfiles, { desc = "Old files" })
vim.keymap.set("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>ss", fzf.builtin, { desc = "FzfLua builtins" })
vim.keymap.set("n", "<leader>s/", fzf.lgrep_curbuf, { desc = "Grep current buffer" })
vim.keymap.set("n", "<leader>*", fzf.grep_cword, { desc = "Grep word under cursor" })
vim.keymap.set("v", "<leader>*", fzf.grep_visual, { desc = "Grep word under cursor" })
vim.keymap.set("n", '<leader>s"', fzf.registers, { desc = "Registers" })
vim.keymap.set("n", "<leader>sm", fzf.marks, { desc = "Marks" })
vim.keymap.set("n", "<leader>sc", fzf.command_history, { desc = "Command history" })
vim.keymap.set("n", "<leader>st", fzf.treesitter, { desc = "Treesitter symbols" })
vim.keymap.set("n", "<leader>sj", fzf.jumps, { desc = "Jumps" })

---------- 5_FILES
require('mini.files').setup({
    mappings = {
        go_in_plus = '<CR>',
    },
})
vim.keymap.set('n', '\\', function()
    local mf = require('mini.files')
    if not mf.close() then
        mf.open()
    end
end, { desc = "File explorer" })
vim.keymap.set('n', '|', function()
    local mf = require('mini.files')
    if not mf.close() then
        mf.open(vim.api.nvim_buf_get_name(0))
    end
end, { desc = "File explorer (current file)" })

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
        vim.keymap.set('n', '<Leader>o', function()
            local entry = require('mini.files').get_fs_entry()
            if entry then
                vim.fn.jobstart({ 'xdg-open', entry.path }, { detach = true })
            end
        end, { buffer = args.data.buf_id, desc = "Open with xdg-open" })
    end,
})

---------- 6_TERMINAL
require('toggleterm').setup({
    open_mapping = [[<C-`>]],
    direction = 'float',
})
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

local function toggle_adjacent_term(direction)
    local tt = require('toggleterm.terminal')
    local focused = tt.get_focused_id()
    if not focused then return end
    local terms = tt.get_all()
    for i, t in ipairs(terms) do
        if t.id == focused then
            local idx = i + direction
            if idx < 1 then idx = #terms end
            if idx > #terms then idx = 1 end
            local next = terms[idx]
            t:close()
            next:open()
            return
        end
    end
end

-- <M-h>/<M-l> do double duty: cycle terminals when you're in one, resize the
-- window otherwise (toggle_adjacent_term is a no-op outside a terminal anyway).
local function term_or_resize(dir)
    return function()
        if vim.bo.buftype == 'terminal' then
            toggle_adjacent_term(dir)
        else
            vim.cmd('5wincmd ' .. (dir == 1 and '>' or '<'))
        end
    end
end
vim.keymap.set({ 'n', 't' }, '<M-l>', term_or_resize(1), { desc = 'Next terminal / grow window' })
vim.keymap.set({ 'n', 't' }, '<M-h>', term_or_resize(-1), { desc = 'Prev terminal / shrink window' })

---------- 7_TREESITTER
require('nvim-treesitter').install({
    "python", "lua", "javascript", "typescript", "tsx", "rust", "go",
    "c", "cpp", "bash", "json", "yaml", "markdown", "nix", "just",
    "html", "css", "toml", "gdscript", "java", "dart", "sql",
    "cmake", "swift", "kotlin", "ruby", "elixir", "vim",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Python custom indent
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

_G.custom_python_indent = custom_python_indent

vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        vim.bo.indentexpr = "v:lua.custom_python_indent()"
        vim.bo.indentkeys = "0{,0},0),0],:,!^F,o,O,e,<:>,=elif,=except"
    end,
})

vim.api.nvim_create_user_command('Ast', function() vim.cmd(":InspectTree") end, {})

-- treesj
vim.keymap.set('n', '<leader>m', require('treesj').toggle, { desc = "Toggle scope" })

---------- 8_LSP
local blink = require 'blink.cmp'

blink.setup {
    signature = {
        enabled = true,
    },
    completion = {
        documentation = {
            auto_show = true,
        },
    },
}

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
        local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- fzf pickers on nvim's own LSP keys (:h lsp-defaults), overriding the
        -- default handlers. grn/gra/grx keep their builtin behaviour.
        map('gd', fzf.lsp_definitions, 'Definition')
        map('grr', fzf.lsp_references, 'References')
        map('gri', fzf.lsp_implementations, 'Implementation')
        map('grt', fzf.lsp_typedefs, 'Type definition')
        map('gO', fzf.lsp_document_symbols, 'Outline')
        map('<leader>ws', fzf.lsp_workspace_symbols, 'Workspace symbols')
        -- gD is Goto Declaration, not Definition: in C this lands in the header.
        map('gD', vim.lsp.buf.declaration, 'Declaration')

        -- Inlay hints, if the server supports them. Off by default: they displace code.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
            end, '[T]oggle Inlay [H]ints')
        end

    end,
})

require('fidget').setup {}
local servers = {
    lua_ls = {
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                },
                workspace = {
                    preloadFileSize = 10000,
                    library = {
                        vim.env.VIMRUNTIME,
                        vim.fn.stdpath("data") .. "/site",
                    }
                },
            },
        },
    },
    jsonls = {},
    pyright = {},
    -- pyrefly = {},
    ruff = {},
    rust_analyzer = {},
    nixd = {},
    clangd = {},
    marksman = {},
    -- harper_ls = {},
    dartls = {},
    gdscript = {},
    ts_ls = {},
}

for server, config in pairs(servers) do
    vim.lsp.config(server, config)
end
vim.lsp.enable(vim.tbl_keys(servers))

---------- 9_DAP
vim.cmd("hi DapBreakpointColor guifg=#fa4848")
vim.fn.sign_define("DapBreakpoint", {
    text = "●",
    texthl = "DapBreakpointColor",
    linehl = "",
    numhl = "",
})

vim.cmd("hi DapStopped guifg=#fa4848")
vim.fn.sign_define('DapStopped', {
    text = "→",
    texthl = 'DapStopped',
    linehl = '',
    numhl = '',
})

local dap = require('dap')
local dapui = require('dapui')
require("nvim-dap-virtual-text").setup {}
dapui.setup()

dap.listeners.before.attach.dapui_config = function()
    dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
    dapui.open()
end

local function set_debug_keymaps()
    vim.keymap.set('n', '<Right>', dap.step_into, { desc = 'DAP Step Into' })
    vim.keymap.set('n', '<Left>', dap.step_out, { desc = 'DAP Step Out' })
    vim.keymap.set('n', '<Down>', dap.step_over, { desc = 'DAP Step Over' })
    vim.keymap.set('n', '<Up>', dap.step_back, { desc = 'DAP Step Back' })
end

local function clear_debug_keymaps()
    pcall(vim.keymap.del, 'n', '<Right>')
    pcall(vim.keymap.del, 'n', '<Left>')
    pcall(vim.keymap.del, 'n', '<Down>')
    pcall(vim.keymap.del, 'n', '<Up>')
end

dap.listeners.after.event_initialized["debug_keys"] = function()
    set_debug_keymaps()
end
dap.listeners.before.event_terminated["debug_keys"] = function()
    clear_debug_keymaps()
end
dap.listeners.before.event_exited["debug_keys"] = function()
    clear_debug_keymaps()
end

vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = "[D]ebug [U]I toggle" })
vim.keymap.set('n', '<leader>B', dap.run_to_cursor, { desc = "Dap run to cursor" })
vim.keymap.set('n', '<F1>', dap.continue, { desc = "Dap continue" })
vim.keymap.set('n', '<F2>', dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set('n', '<F3>', function()
    dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, { desc = "Breakpoint log message" })

dap.adapters.python = function(cb, _)
    cb({
        type = 'executable',
        command = vim.fn.exepath('python3'),
        args = { '-m', 'debugpy.adapter' },
        options = {
            source_filetype = 'python',
        },
    })
end
dap.configurations.python = { ---@diagnostic disable-line: inject-field
    {
        type = 'python',
        request = 'launch',
        name = "Launch file",
        program = "${file}",
        pythonPath = function()
            return vim.fn.system("which python"):gsub('%s+', '')
        end,
    },
}

---------- 10_TABS
local bufferline = require('bufferline')
bufferline.setup({
    options = {
        numbers = 'ordinal',
        style_preset = bufferline.style_preset.minimal,
        indicator = {
            style = 'none'
        },
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = { '', '' },
        custom_areas = {
            left = function()
                local tt = require('toggleterm.terminal')
                local terms = tt.get_all()
                if #terms == 0 then return {} end
                local focused = tt.get_focused_id()
                local parts = {}
                for _, t in ipairs(terms) do
                    local id = tostring(t.id)
                    if t.id == focused then
                        table.insert(parts, '[' .. id .. ']')
                    else
                        table.insert(parts, id)
                    end
                end
                return { { text = ' T' .. table.concat(parts, '-'), link = 'Comment' } }
            end,
        },
    },
})

vim.keymap.set('n', '<leader>bd', '<cmd>bd<cr>', { desc = "Close buffer" })
vim.keymap.set('n', '<leader>ba', function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "terminal" then
            vim.api.nvim_buf_delete(buf, {})
        end
    end
end, { desc = "Close all buffers" })
vim.keymap.set('n', '<leader>bo', '<cmd>BufferLineCloseOthers<cr>', { desc = "Close other buffers" })
vim.keymap.set('n', '<leader>br', '<cmd>BufferLineCloseRight<cr>', { desc = "Close buffers to the right" })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineCloseLeft<cr>', { desc = "Close buffers to the left" })
vim.keymap.set('n', '<leader>bn', '<cmd>BufferLineCycleNext<cr>', { desc = "Next tab" })
vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineCyclePrev<cr>', { desc = "Prev tab" })
vim.keymap.set('n', '<leader>bt', '<cmd>BufferLineTogglePin<cr>', { desc = "Pin current tab" })
vim.keymap.set('n', '<leader>bu', '<cmd>BufferLineGroupClose ungrouped<cr>', { desc = "Close non-pinned tabs" })

for i = 1, 9, 1 do
    vim.keymap.set(
        'n',
        '<M-' .. i .. '>',
        function() bufferline.go_to(i, true) end,
        { desc = "Open buffer " .. i }
    )
    vim.keymap.set(
        'n',
        '<leader>bm' .. i,
        function() bufferline.move_to(i) end,
        { desc = "Move buffer to " .. i }
    )
end

---------- 11_GIT
require('neogit').setup {}
vim.keymap.set('n', '<leader>g', '<Cmd>Neogit<CR>', { desc = "Neogit" })

require('gitsigns').setup {
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Actions
        map('n', '<leader>j', function() gitsigns.nav_hunk('next') end)
        map('n', '<leader>k', function() gitsigns.nav_hunk('prev') end)
    end,
}

---------- 12_FORMATTER
vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('format-on-save', { clear = true }),
    callback = function() vim.lsp.buf.format({ timeout_ms = 500 }) end,
})

vim.keymap.set('n', '<leader>W', '<cmd>noautocmd w<cr>', { desc = "Save without formatting" })

---------- 13_EXTRA
local dial_map = require("dial.map")
vim.keymap.set("n", "<leader>=", function() dial_map.manipulate("increment", "normal") end, { desc = 'increment' })
vim.keymap.set("n", "<leader>-", function() dial_map.manipulate("decrement", "normal") end, { desc = 'decrement' })
vim.keymap.set("n", "g<C-a>", function() dial_map.manipulate("increment", "gnormal") end)
vim.keymap.set("n", "g<C-x>", function() dial_map.manipulate("decrement", "gnormal") end)
vim.keymap.set("v", "<leader>=", function() dial_map.manipulate("increment", "visual") end)
vim.keymap.set("v", "<leader>-", function() dial_map.manipulate("decrement", "visual") end)
vim.keymap.set("v", "g<C-a>", function() dial_map.manipulate("increment", "gvisual") end)
vim.keymap.set("v", "g<C-x>", function() dial_map.manipulate("decrement", "gvisual") end)

local augend = require("dial.augend")
require("dial.config").augends:register_group {
    default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.date.new {
            pattern = "%A",
            default_kind = "day",
            only_valid = true,
            word = true,
        },
        augend.constant.new { elements = { "and", "or" }, word = true, cyclic = true },
        augend.constant.new { elements = { "false", "true" }, word = true, cyclic = true },
        augend.constant.new { elements = { "False", "True" }, word = true, cyclic = true },
        augend.constant.new { elements = { "off", "on" }, word = true, cyclic = true },
        augend.constant.new { elements = { "Off", "On" }, word = true, cyclic = true },
        augend.constant.new { elements = { "no", "yes" }, word = true, cyclic = true },
        augend.constant.new { elements = { "No", "Yes" }, word = true, cyclic = true },
        augend.constant.new {
            elements = { "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday" },
            word = true, cyclic = true,
        },
        augend.constant.new {
            elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
            word = true, cyclic = true,
        },
        augend.constant.new {
            elements = { "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta",
                "iota", "kappa", "lambda", "mu", "nu", "xi", "omicron", "pi", "rho",
                "sigma", "tau", "upsilon", "phi", "chi", "psi", "omega" },
            word = true, cyclic = true,
        },
        augend.constant.new {
            elements = { "Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta",
                "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho",
                "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega" },
            word = true, cyclic = true,
        },
        augend.constant.new {
            elements = { "α", "β", "γ", "δ", "ε", "ζ", "η", "θ",
                "ι", "κ", "λ", "μ", "ν", "ξ", "ο", "π",
                "ρ", "σ", "τ", "υ", "φ", "χ", "ψ", "ω" },
            word = true, cyclic = true,
        },
        augend.constant.new {
            elements = { "Α", "Β", "Γ", "Δ", "Ε", "Ζ", "Η", "Θ",
                "Ι", "Κ", "Λ", "Μ", "Ν", "Ξ", "Ο", "Π",
                "Ρ", "Σ", "Τ", "Υ", "Φ", "Χ", "Ψ", "Ω" },
            word = true, cyclic = true,
        },
        augend.constant.new {
            elements = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
                "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" },
            word = false, cyclic = true,
        },
        augend.constant.new {
            elements = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
                "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z" },
            word = false, cyclic = true,
        },
    }
}

-- undotree (built-in nvim 0.12 :Undotree via packadd nvim.undotree is lame, using plugin)
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { desc = "Open [U]ndotree" })

require('which-key').setup({
    preset = "helix",
    delay = 0,
})

-- Inline search count "[1/345]" (builtin shows >99 after 99 matches)
require('hlslens').setup()
vim.keymap.set('n', 'n',
    [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
    { silent = true })
vim.keymap.set('n', 'N',
    [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
    { silent = true })
vim.keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], { silent = true })
vim.keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], { silent = true })
vim.keymap.set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], { silent = true })
vim.keymap.set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], { silent = true })
