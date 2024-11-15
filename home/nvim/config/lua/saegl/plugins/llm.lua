return {
    "David-Kunz/gen.nvim",
    keys = {
        {
            '<leader>l',
            ':Gen<cr>',
            mode = { 'n', 'v' },
            desc = '[L]lm',
        },
    },
    opts = {
        model = "llama3.1",
        show_prompt = true,
        show_model = true,
    },
}
