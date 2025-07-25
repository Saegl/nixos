-- Move lines up and down in visual selection
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Window resize
vim.keymap.set("n", "<M-h>", "<C-w>5<")
vim.keymap.set("n", "<M-j>", "<C-w>-")
vim.keymap.set("n", "<M-k>", "<C-w>+")
vim.keymap.set("n", "<M-l>", "<C-w>5>")

-- Horizontal movement
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- System clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", [["+p]], { desc = "Paste from system clipboard" })

-- "q:" is driving me crazy, but even this keymap cannot kill it entirely
-- if you do 'q<long_wait>:' it will open history anyway
vim.keymap.set('n', 'q:', ':q')

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- TODO: TRY Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal mode -> Normal mode
-- NOTE: This won't work in all terminal emulators/tmux/etc
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- function _G.set_terminal_keymaps()
--     local opts = { buffer = 0 }
--     vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)           -- Allow switching to normal mode
--     vim.keymap.set('t', 'q', [[<C-\><C-n><cmd>close<CR>]], opts) -- Close terminal with 'q'
-- end
--
-- vim.cmd [[
--   autocmd TermOpen term://*toggleterm#* setlocal nonumber norelativenumber
--   autocmd TermOpen term://*toggleterm#* nnoremap <buffer> q <cmd>close<CR>
-- ]]
--
-- vim.cmd [[
--   autocmd TermOpen term://*toggleterm#* startinsert  " Ensure terminal starts in insert mode
--   autocmd TermOpen term://*toggleterm#* nnoremap <buffer> q <cmd>ToggleTerm<CR>  " Close with 'q' in normal mode
-- ]]
--
-- vim.cmd 'autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()'

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*toggleterm#*",
    callback = function()
        vim.cmd("startinsert") -- Ensure terminal always starts in insert mode
        vim.api.nvim_buf_set_keymap(0, "n", "H", "<cmd>bd!<CR>", { noremap = true, silent = true })
    end,
})

-- Regular editor behavior
vim.keymap.set({ 'n', 'i' }, '<C-s>', '<cmd>w<cr><esc>', { desc = "save" })
vim.keymap.set({ 'n', 'v' }, '<C-a>', '<C-\\><C-n>ggVG', { desc = "select all" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
