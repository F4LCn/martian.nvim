local M = {}

function M.setup()
  local ok, ts_context_commentstring = pcall(require, "ts_context_commentstring")
  if not ok then
    return
  end

  ts_context_commentstring.setup({
    enable_autocmd = false,
  })
end

function M.get_plugin_config()
  return {
    {
      "JoosepAlviste/nvim-ts-context-commentstring",
      config = M.setup,
      event = "User FileOpened",
    },
  }
end

return M
