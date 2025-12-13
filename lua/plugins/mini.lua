local M = {}

function M.setup()
  local mini_ai_ok, mini_ai = pcall(require, "mini.ai")
  local mini_surround_ok, mini_surround = pcall(require, "mini.surround")
  if mini_ai_ok then
    mini_ai.setup()
  end
  if mini_surround_ok then
    mini_surround.setup()
  end

  -- setup mini.notify if available and wire it to core.log
  local ok, mini_notify = pcall(require, "mini.notify")
  if ok and mini_notify and mini_notify.setup then
    local window_config = function()
      return {
          anchor = "SE",
          border = "rounded",
          col = vim.o.columns,
          row = vim.o.lines - (vim.o.cmdheight + 1),
          width = math.max(math.floor(vim.o.columns / 4), 45),
        }
    end
    mini_notify.setup({
      window = {
        config = window_config,
      },
    })
    pcall(function()
      local Log = require("core.log")
      if Log and Log.configure_notifications then
        Log:configure_notifications(mini_notify.notify)
      end
    end)
  end
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
