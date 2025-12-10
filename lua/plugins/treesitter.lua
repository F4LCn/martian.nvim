local M = {}

function M.setup()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
  if not status_ok then
    return
  end

  treesitter_configs.setup({
    on_config_done = nil,
    ensure_installed = { "lua", "comment", "markdown_inline", "regex", "c", "cpp", "vimdoc", "rust", "c_sharp" },
    ignore_install = {},
    sync_install = false,
    auto_install = false,
    matchup = {
      enable = false, -- mandatory, false will disable the whole extension
    },
    highlight = {
      enable = true, -- false will disable the whole extension
      additional_vim_regex_highlighting = false,
      disable = function(lang, buf)
        if vim.tbl_contains({ "latex" }, lang) then
          return true
        end

        local status_ok, big_file_detected = pcall(vim.api.nvim_buf_get_var, buf, "bigfile_disable_treesitter")
        return status_ok and big_file_detected
      end,
    },
    indent = { enable = true, disable = { "yaml", "python" } },
    autotag = { enable = false },
    textobjects = {
      swap = {
        enable = false,
      },
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["ia"] = "@parameter.inner",
          ["aa"] = "@parameter.outer",
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
          ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          ["ib"] = "@block.inner",
          ["ob"] = "@block.outer",
        },
      },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        node_decremental = '<C-W>',
      },
    },
    textsubjects = {
      enable = false,
      keymaps = { ["."] = "textsubjects-smart", [";"] = "textsubjects-big" },
    },
    playground = {
      enable = true,
      disable = {},
      updatetime = 25,         -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false, -- Whether the query persists across vim sessions
      keybindings = {
        toggle_query_editor = "o",
        toggle_hl_groups = "i",
        toggle_injected_languages = "t",
        toggle_anonymous_nodes = "a",
        toggle_language_display = "I",
        focus_language = "f",
        unfocus_language = "F",
        update = "R",
        goto_node = "<cr>",
        show_help = "?",
      },
    },
  })

  local ts_utils = require "nvim-treesitter.ts_utils"
  ts_utils.is_in_node_range = vim.treesitter.is_in_node_range
  ts_utils.get_node_range = vim.treesitter.get_node_range
end

function M.get_plugin_config()
  return {
    {
      "nvim-treesitter/nvim-treesitter",
      config = M.setup,
      build = ":TSUpdate",
      cmd = {
        "TSInstall",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
        "TSInstallInfo",
        "TSInstallSync",
        "TSInstallFromGrammar",
      },
      event = "User FileOpened",
    },
    {
      "romgrk/nvim-treesitter-context",
      config = function()
        require("treesitter-context").setup {
          enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
          throttle = true, -- Throttles plugin updates (may improve performance)
          max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        }
      end
    },
  }
end

return M
