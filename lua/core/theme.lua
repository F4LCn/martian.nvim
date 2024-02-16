local M = {}

M.config = function()
  builtin.theme = {
    name = "oxocharcoal",
    options = {},
  }
end

M.setup = function()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  local selected_theme = builtin.theme.name

  local status_ok, plugin = pcall(require, selected_theme)
  if not status_ok then
    return
  end
  pcall(function()
    plugin.setup(builtin.theme[selected_theme].options)
  end)

  vim.g.colors_name = selected_theme
  vim.cmd("colorscheme " .. selected_theme)

  if package.loaded.lualine then
    require("core.lualine").setup()
  end
  if package.loaded.lir then
    require("core.lir").icon_setup()
  end
end

return M
