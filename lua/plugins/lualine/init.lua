local M = {}

M.setup = function()
  local status_ok, lualine = pcall(require, "lualine")
  if not status_ok then
    return
  end

  local style = require("plugins.lualine.styles").style

  ---@diagnostic disable-next-line: redundant-parameter
  lualine.setup(style)
end

function M.get_plugin_config()
  return {
    {
      "nvim-lualine/lualine.nvim",
      config = M.setup,
      event = "VimEnter",
    },
  }
end

return M
