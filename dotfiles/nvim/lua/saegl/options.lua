vim.opt.number = true
vim.opt.relativenumber = false

-- Turn '~' into operator ('~' is swapcase action)
vim.opt.tildeop = true

-- Enable mouse in all modes, in 'nvi' by default
vim.opt.mouse = 'a'

vim.opt.winborder = "rounded"

-- Remove this duplicate '--INSERT--' on last line, when going to insert mode
vim.o.laststatus = 0
vim.o.ruler = false
vim.opt.showmode = false
vim.opt.showcmd = false
vim.o.undofile = true

-- Preserve indentation on wrapped (long lines)
vim.opt.breakindent = true
vim.opt.showbreak = '>>'

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true -- ignore case in search
vim.opt.smartcase = true  -- ignore 'ignore' if pattern contains uppercase letters

-- always draw leftest column for signs (git, breakpoints etc)
vim.opt.signcolumn = 'yes'

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- print debugging going wild
vim.o.scrollback = 20000

-- Enable spell checking
-- vim.opt.spelllang = 'en_us'
-- vim.opt.spell = true

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Wrap <Left> <Right>, in normal mode (<,>) and insert mode ([,])
vim.opt.whichwrap = "b,s,<,>,[,]"

-- Preview substitutions
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 5

vim.opt.tabstop = 4      -- <Tab> size
vim.opt.shiftwidth = 4   -- Number of spaces for (auto)indent
vim.opt.expandtab = true -- Substitute <Tab> with spaces
