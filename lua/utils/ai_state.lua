local M = {}

-- Global AI completion state (defaults to disabled)
M.enabled = false

-- Toggle AI completion on/off
function M.toggle()
  M.enabled = not M.enabled
  vim.notify("AI Completion " .. (M.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
  -- Trigger lualine refresh to update status bar
  if pcall(require, "lualine") then
    require("lualine").refresh()
  end
  return M.enabled
end

-- Enable AI completion
function M.enable()
  M.enabled = true
  vim.notify("AI Completion enabled", vim.log.levels.INFO)
  if pcall(require, "lualine") then
    require("lualine").refresh()
  end
end

-- Disable AI completion
function M.disable()
  M.enabled = false
  vim.notify("AI Completion disabled", vim.log.levels.INFO)
  if pcall(require, "lualine") then
    require("lualine").refresh()
  end
end

-- Get current state
function M.is_enabled()
  return M.enabled
end

return M
