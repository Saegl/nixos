-- Must happen before plugins loading
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.guifont = "FiraCode Nerd Font Mono"

require 'saegl.options'
require 'saegl.keymaps'
require 'saegl.abbrevs'
require 'saegl.runner'
require 'saegl.config'
require 'saegl.neovide'
require 'saegl.lazy'
