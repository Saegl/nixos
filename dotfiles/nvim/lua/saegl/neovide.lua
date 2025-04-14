if not vim.g.neovide then
    return
end

-- vim.o.guifont = 'Fantasque Sans Mono'
-- font=IosevkaTerm Nerd Font Propo:size=24.0
vim.o.guifont = 'IosevkaTerm Nerd Font Propo'
vim.g.neovide_scale_factor = 1.8
vim.g.neovide_scroll_animation_length = 0.2
vim.g.neovide_hide_mouse_when_typing = true
--
-- vim.g.neovide_transparency = 1.0
-- vim.g.neovide_normal_opacity = 1.0
--
vim.g.neovide_refresh_rate = 165
vim.g.neovide_refresh_rate_idle = 5

vim.g.neovide_profiler = false

vim.g.neovide_cursor_vfx_mode = "" -- set 'pixiedust' to enable
vim.g.neovide_cursor_vfx_opacity = 500.0
vim.g.neovide_cursor_vfx_particle_lifetime = 3.0
vim.g.neovide_cursor_vfx_particle_density = 100.0

vim.g.neovide_fullscreen = false
