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
    backend = { "telescope" },
  })
end

function M.get_plugin_config()
  return {
    { 'stevearc/dressing.nvim', config = M.setup },
  }
end

return M
