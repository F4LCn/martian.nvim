local M = {}

function M.setup()
  local ai_state = require "utils.ai_state"

  -- Configure copilot with virtual text only
  require('copilot').setup {
    suggestion = {
      enabled = false,
      auto_trigger = false,
      debounce = 75,
      keymap = {
        accept = false,
        accept_word = false,
        accept_line = "<M-y>",
        next = "<M-(>",
        prev = "<M-)>",
        dismiss = "<M-n>",
      },
    },
    panel = {
      enabled = false,
    },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,
    },
    server_opts_overrides = {
      settings = {
        advanced = {
          listCount = 1,
          inlineSuggestCount = 1,
        }
      },
    }
  }
  
end

function M.get_plugin_config()
  return {
    {
      "zbirenbaum/copilot.lua",
      config = M.setup,
    },
  }
end

return M
