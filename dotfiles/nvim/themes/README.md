# themes/

Every colorscheme here is plain data: `<name>.toml` maps highlight groups to colors.
Nothing is downloaded and no theme code runs.

- `lua/toml_theme.lua` reads a TOML file and applies it (`hi clear`, then `nvim_set_hl`
  for each group, then the terminal colors).
- `colors/<name>.lua` is a one-line stub that calls the loader, so `:colorscheme <name>`
  works. The TOML files can't go in `colors/` themselves: `:colorscheme` runs any
  `colors/<name>.*` it finds, `.toml` included.
- `lua/theme.lua` is the `:Theme` picker. It lists everything in this directory and keeps
  your own per-theme overrides, which run after the theme loads.

## Format

```toml
name = "tokyonight-night"
source = "https://github.com/folke/tokyonight.nvim"   # shown in the picker
background = "dark"

[palette]              # names for colors, used below
bg = "#1a1b26"

[terminal]             # g:terminal_color_0 .. 15
0 = "black"

[highlights]
Normal = { fg = "fg", bg = "bg" }            # attributes: fg bg sp blend, bold italic ... = true
CursorLine = { bg = "#292e42" }              # a color is a palette name, '#rrggbb' or 'NvimDarkRed'
"@variable.builtin" = "Special"              # a string links to another group
LspInlayHint = { link = "Comment", default = true }
```

Each file is split into sections: Neovim's own groups (UI, syntax, Treesitter, LSP,
diagnostics, filetype syntax), then one section per plugin.

## Converting a theme

```sh
nvim -l scripts/theme2toml.lua <name> <git-url-or-dir> [--colorscheme <cs>] [--before <lua>]
```

Run it from the config root. It writes `themes/<name>.toml` and `colors/<name>.lua`. Add
the name to the picker by restarting; `:Theme <name>` switches to it.

- `<name>` is what the theme is called here.
- `--colorscheme` is the upstream `:colorscheme` name, if it differs from `<name>`.
- `--before` is Lua that runs before `:colorscheme`, for theme options:

```sh
# a plain one
nvim -l scripts/theme2toml.lua tokyonight-night https://github.com/folke/tokyonight.nvim
# options through setup()
nvim -l scripts/theme2toml.lua onedark-warm https://github.com/navarasu/onedark.nvim \
    --colorscheme onedark --before "require('onedark').setup { style = 'warm' }"
# options through globals, and a light variant
nvim -l scripts/theme2toml.lua everforest-light https://github.com/sainnhe/everforest \
    --colorscheme everforest \
    --before "vim.o.background = 'light'; vim.g.everforest_background = 'medium'; vim.g.everforest_better_performance = 1"
```

To regenerate an existing theme, or update it to a newer upstream, the first two lines of
its TOML file record the source, revision, `:colorscheme` name and `--before` used.

### How it works

The theme runs in a fresh `nvim --clean` with its own XDG directories, so your plugins
and caches are not involved. Every built-in syntax file is loaded first, then the theme.
The converter records every highlight group the theme changed compared with Neovim's
defaults. Groups the theme left exactly as a syntax file sets them are skipped, because
the syntax file sets them again when you open that filetype. This captures the theme's
output, so it doesn't matter whether the theme is Vim script, Lua, compiled or generated.

Colors are named after the variables in the theme's own source (`.lua`, `.vim`, `.json`):
`red = "#..."`, `'red': ['#...', 1]`, `red = Color.new("#...")`, `red = { default = "#..." }`.
When several colors could take the same name, the most-used one gets it. A color within
2 per channel of a source color takes that name but keeps its own value: some themes
convert through HSL, and the round trip shifts colors by one. Colors with no match, such
as blends the theme computes, stay as `#rrggbb`.

At the end the converter loads the TOML through `toml_theme.lua` and compares every group
with the original. It fails and lists the differences if anything doesn't match.

### Themes that look at your setup

Some themes style only the plugins they find installed. The converter's clean Neovim has
no plugins, so tell such a theme everything is installed:

- catppuccin (`auto_integrations`, via `vim.pack.get()`):

  ```sh
  --before "vim.pack.get = function() return vim.tbl_map(function(n) return { spec = { name = n } } end, vim.tbl_keys(require('catppuccin.utils.integration_mappings'))) end"
  ```

- tokyonight and jellybeans style every plugin unless lazy.nvim is loaded, so they need
  nothing.

If a theme styles only a few plugins, look for `vim.pack.get`, `lazy.core.config` or
`package.loaded` in its source.
