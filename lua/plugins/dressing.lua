local M = {}

function M.setup()
  local dressing = require "dressing"

  dressing.setup({
    relative = "editor",
    input = {
      relative = "editor",
    },
    select = {
      backend = { "builtin" },
    }
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
