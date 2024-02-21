vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

Icons = require("icons")

require("plugin-manager"):init()

local keymaps = require "keymaps"
keymaps.load_keymap()

local configs = require "configs"
configs.init()

local autocmds = require "autocmds"
autocmds.load_defaults()

local lazy_opts = require "lazy-opts"
local plugins = require('plugins')
local plugin_configs = plugins:configs()
require('lazy').setup(plugin_configs, lazy_opts)

require("core.log"):init()

local lsp = require "lsp"
lsp.setup()

local theme = require "plugins.theme"
theme.setup()

local Log = require "core.log"
Log:debug "Starting nvim :)"
