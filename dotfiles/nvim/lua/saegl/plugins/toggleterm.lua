return {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
        direction = 'tab',
        size = 20,
        open_mapping = [[<c-`>]],
    },
    config = function(_, opts)
        local toggleterm = require 'toggleterm'
        toggleterm.setup(opts)

        local Terminal = require('toggleterm.terminal').Terminal

        function PyTerm()
            local name = vim.api.nvim_buf_get_name(0)
            local python = Terminal:new({
                cmd = ("python -i " .. name),
                display_name = name,
                direction = "float",
            })
            python:toggle()
        end

        vim.keymap.set('n', '<leader>xp', '<cmd>lua PyTerm()<cr>')
        vim.keymap.set('n', 'v<C-`>', '<cmd>ToggleTerm direction=float<cr>')

        vim.keymap.set("n", "<leader>`", function()
            local dir = vim.fn.expand("%:p:h")
            require("toggleterm.terminal").Terminal:new({
                dir = dir,
                direction = "float",
            }):toggle()
        end, { noremap = true, silent = true })


        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local Terminal = require("toggleterm.terminal").Terminal

        function run_just_recipe()
            local handle = io.popen("just --list")
            if not handle then return end
            local result = handle:read("*a")
            handle:close()

            local recipes = {}
            local skip_first_line = true -- Ignore the first line ("Available recipes:")

            for line in result:gmatch("[^\r\n]+") do
                if skip_first_line then
                    skip_first_line = false
                else
                    local recipe = line:match("^%s*(%S+)") -- Extract only the first word (recipe name)
                    if recipe then
                        table.insert(recipes, recipe)
                    end
                end
            end

            if #recipes == 0 then
                vim.notify("No recipes found in justfile!", vim.log.levels.ERROR)
                return
            end

            pickers.new({}, {
                prompt_title = "Choose Just Recipe",
                finder = finders.new_table({ results = recipes }),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    local function run_selected()
                        local selection = action_state.get_selected_entry()
                        if not selection then return end
                        actions.close(prompt_bufnr)

                        local term = Terminal:new({
                            cmd = string.format("bash -c 'just %s; exec $SHELL'", selection[1]),
                            direction = "float",
                            close_on_exit = true,
                        })
                        term:toggle()
                    end

                    map("i", "<CR>", run_selected)
                    map("n", "<CR>", run_selected)

                    return true
                end,
            }):find()
        end

        vim.api.nvim_set_keymap("n", "<leader>xj", "<cmd>lua run_just_recipe()<CR>", { noremap = true, silent = true })



        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values

        local function run_mypy()
            local handle = io.popen("mypy --strict . 2>&1")
            if not handle then return end

            local result = handle:read("*a")
            handle:close()

            local lines = {}
            for line in result:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end

            pickers.new({}, {
                prompt_title = "mypy --strict .",
                finder = finders.new_table({ results = lines }),
                sorter = conf.generic_sorter({})
            }):find()
        end

        vim.keymap.set("n", "<leader>xm", run_mypy, { noremap = true, silent = true })

        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values

        local function run_pytest()
            local handle = io.popen("pytest --tb=short 2>&1")
            if not handle then return end

            local result = handle:read("*a")
            handle:close()

            local lines = {}
            for line in result:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end

            if #lines == 0 then
                table.insert(lines, "No test output!")
            end

            pickers.new({}, {
                prompt_title = "pytest results",
                finder = finders.new_table({ results = lines }),
                sorter = conf.generic_sorter({})
            }):find()
        end

        vim.keymap.set("n", "<leader>xt", run_pytest, { noremap = true, silent = true })


        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values

        local function run_ruff()
            local handle = io.popen("ruff check . 2>&1")
            if not handle then return end

            local result = handle:read("*a")
            handle:close()

            local lines = {}
            for line in result:gmatch("[^\r\n]+") do
                table.insert(lines, line)
            end

            if #lines == 0 then
                table.insert(lines, "No issues found!")
            end

            pickers.new({}, {
                prompt_title = "ruff check",
                finder = finders.new_table({ results = lines }),
                sorter = conf.generic_sorter({})
            }):find()
        end

        vim.keymap.set("n", "<leader>xr", run_ruff, { noremap = true, silent = true })
    end,
}
