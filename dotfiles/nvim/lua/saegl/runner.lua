function run_current_file()
    local file_path = vim.api.nvim_buf_get_name(0)

    if file_path:match("%.config/waybar/config%.jsonc$") then
        os.execute("pkill waybar && waybar &")
        print("Waybar restarted")
    else
        print("No specific action defined for this file")
    end
end

vim.keymap.set(
    'n',
    '<F6>',
    function() run_current_file() end,
    { noremap = true, silent = true }
)
