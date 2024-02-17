vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

Builtin = {}
Icons = require("icons")
Lsp = {}

require("plugin-manager"):init()

local keymaps = require "keymaps"
keymaps.load_keymap()

local builtins = require "core.builtins"
builtins.config()

local configs = require "configs"
configs.init()

local autocmds = require "autocmds"
autocmds.load_defaults()

local lazy_opts = require "lazy-opts"
require('lazy').setup('plugins', lazy_opts)

local theme = require "core.theme"
theme.setup()
