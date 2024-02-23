local M = {}

function M.setup()
  require("neodim").setup({
    hide = {
      virtual_text = false,
      signs = false,
      underline = false,
    }
  })
end

function M.get_plugin_config()
  return {
    "zbirenbaum/neodim",
    config = M.setup
  }
end

return M
