local M = {}

function M.config()
  builtin.mason = {
    ui = {
      border = "rounded",
    },

    icons = {
      package_installed = "",
      package_pending = "󱡓",
      package_uninstalled = "",
    },

    max_concurrent_installers = 10,

    on_config_done = nil,
  }
end

function M.setup()
  local status_ok, mason = pcall(require, "mason")
  if not status_ok then
    return
  end

  mason.setup(builtin.mason)

  if builtin.mason.on_config_done then
    builtin.mason.on_config_done(mason)
  end
end

return M
