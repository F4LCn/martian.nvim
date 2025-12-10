local M = {}

function M.get_plugin_config()
  return {
    {
      "MunifTanjim/nui.nvim",
      config = function()
        require('utils.ui').setup()
      end
    },
  }
end

return M
