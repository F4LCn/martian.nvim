local M = {}

function M.setup()
  local status_ok, mason = pcall(require, "mason")
  if not status_ok then
    return
  end

  ---@diagnostic disable-next-line: redundant-parameter
  mason.setup({
    ui = {
      border = "rounded",
    },

    icons = {
      package_installed = "",
      package_pending = "󱡓",
      package_uninstalled = "",
    },
    max_concurrent_installers = 10,
  })
end

function M.get_plugin_config()
  return {
    {
      "williamboman/mason.nvim",
      config = M.setup,
      cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
      build = function()
        pcall(function()
          require("mason-registry").refresh()
        end)
      end,
      event = "User FileOpened",
      lazy = true,
    }
  }
end

return M
