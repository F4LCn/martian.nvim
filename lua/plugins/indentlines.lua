local M = {}

M.setup = function()
  local status_ok, indent_blankline = pcall(require, "ibl")
  if not status_ok then
    return
  end

  indent_blankline.setup({
    enabled = true,
    indent = {
      char = Icons.ui.LineLeft,
      smart_indent_cap = false,
    },
    scope = {
      enabled = true,
      char = Icons.ui.LineLeft,
    },
    whitespace = { highlight = { "Whitespace", "NonText" } },
    exclude = {
      filetypes = {
        "help",
        "startify",
        "dashboard",
        "lazy",
        "neogitstatus",
        "NvimTree",
        "Trouble",
        "text",
      },
      buftypes = { "terminal", "nofile" },
    },
  })
end

function M.get_plugin_config()
  return {
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      config = M.setup,
      event = "User FileOpened",
    },
  }
end

return M
