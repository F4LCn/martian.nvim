local M = {}

function M.setup()
  local mini_ai = require "mini.ai"
  local mini_surround = require "mini.surround"

  mini_ai.setup()
  mini_surround.setup()
end

function M.get_plugin_config()
  return {
    {
      'echasnovski/mini.nvim',
      version = '*',
      config = M.setup
    },
  }
end

return M
