local M = {}

function M.setup()
  local dressing = require "dressing"

  dressing.setup({
    insert_only = false,
    mappings = {
      n = {
        ["<Esc>"] = "Close",
        ["<CR>"] = "Confirm",
      },
      i = {
        ["<Esc>"] = "Close",
        ["<CR>"] = "Confirm",
        ["<Up>"] = "HistoryPrev",
        ["<Down>"] = "HistoryNext",
      },
    },
    input = {
      insert_only = false,
      mappings = {
        n = {
          ["<Esc>"] = "Close",
          ["<CR>"] = "Confirm",
        },
        i = {
          ["<Esc>"] = "Close",
          ["<CR>"] = "Confirm",
          ["<Up>"] = "HistoryPrev",
          ["<Down>"] = "HistoryNext",
        },
      },
      backend = { "builtin" },
    },
    select = {
      insert_only = false,
      mappings = {
        n = {
          ["<Esc>"] = "Close",
          ["<CR>"] = "Confirm",
        },
        i = {
          ["<Esc>"] = "Close",
          ["<CR>"] = "Confirm",
          ["<Up>"] = "HistoryPrev",
          ["<Down>"] = "HistoryNext",
        },
      },
      backend = { "builtin" },
      nui = {
        position = "50%",
        size = nil,
        relative = "editor",
        border = {
          style = "rounded",
        },
        buf_options = {
          swapfile = false,
          filetype = "DressingSelect",
        },
        win_options = {
          winblend = 0,
        },
        max_width = 0.8,
        max_height = 0.4,
        min_width = 40,
        min_height = 10,
      },
    },
  })
end

function M.get_plugin_config()
  return {
    {
      'stevearc/dressing.nvim',
      config = M.setup,
      dependencies = {
        "MunifTanjim/nui.nvim",
      }
    },
  }
end

return M
