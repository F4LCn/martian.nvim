local M = {}

local Log = require("core.log")

function M.setup()
  vim.notify "alpha setup"
  local status_ok, alpha = pcall(require, "alpha")
  if not status_ok then
    Log:error "Couldn't require alpha"
    return
  end

  local config = require("plugins.alpha.config").get_sections()

  local dashboard = require 'alpha.themes.dashboard'
  dashboard.section.header.val = config.header or {}
  dashboard.section.buttons.val = config.buttons or {}
  dashboard.section.footer.val = config.footer or {}

  alpha.setup(dashboard.config)
end

function M.get_plugin_config()
  return {
    {
      "goolord/alpha-nvim",
      config = M.setup,
      event = "VimEnter",
    }
  }
end

return M
