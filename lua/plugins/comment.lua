local M = {}

function M.setup()
  local nvim_comment = require "Comment"

  nvim_comment.setup({
    active = true,
    padding = true,
    sticky = true,
    ignore = "^$",
    mappings = {
      basic = true,
      extra = true,
    },
    toggler = {
      line = "gcc",
      block = "gbc",
    },
    opleader = {
      line = "gc",
      block = "gb",
    },
    extra = {
      above = "gcO",
      below = "gco",
      eol = "gcA",
    },
    pre_hook = function(...)
      local loaded, ts_comment = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
      if loaded and ts_comment then
        return ts_comment.create_pre_hook()(...)
      end
    end,
  })
end

function M.get_plugin_config()
  return {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      lazy = true,
    },
    {
      "numToStr/Comment.nvim",
      config = M.setup,
      keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
      event = "User FileOpened",
    },
  }
end

return M
