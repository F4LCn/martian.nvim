vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

builtin = {}
icons = require("icons")
lsp = {}

require("plugin-manager"):init()

local keymaps = require "keymaps"
keymaps.init()

local builtins = require "builtins"
builtins.config()

local configs = require "configs"
configs.init()

local autocmds = require "autocmds"
autocmds.load()

local lazy_opts = require "lazy-opts"
require('lazy').setup('plugins', lazy_opts)

local theme = require "core.theme"
theme.setup()
