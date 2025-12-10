local M = {}

M.enabled = false

function M.toggle()
  M.enabled = not M.enabled
  vim.notify("AI Completion " .. (M.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
  if pcall(require, "lualine") then
    require("lualine").refresh()
  end
  return M.enabled
end

function M.enable()
  M.enabled = true
  vim.notify("AI Completion enabled", vim.log.levels.INFO)
  if pcall(require, "lualine") then
    require("lualine").refresh()
  end
end

function M.disable()
  M.enabled = false
  vim.notify("AI Completion disabled", vim.log.levels.INFO)
  if pcall(require, "lualine") then
    require("lualine").refresh()
  end
end

function M.is_enabled()
  return M.enabled
end

return M
