local M = {}

M.setup = function()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  local status_ok, plugin = pcall(require, "tasogare")
  if not status_ok then
    return
  end
  pcall(function()
    plugin.setup()
  end)

  vim.g.colors_name = "tasogare"
  vim.cmd("colorscheme tasogare")

  if package.loaded.lualine then
    require("plugins.lualine").setup()
  end
  if package.loaded.lir then
    require("plugins.lir").icon_setup()
  end
end

function M.get_plugin_config()
  return {
    {
      "F4LCn/tasogare.nvim",
    }
  }
end

return M
