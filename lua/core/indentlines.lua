local M = {}

M.config = function()
  Builtin.indentlines = {
    active = true,
    on_config_done = nil,
    options = {
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
    },
  }
end

M.setup = function()
  local status_ok, indent_blankline = pcall(require, "ibl")
  if not status_ok then
    return
  end

  indent_blankline.setup(Builtin.indentlines.options)

  if Builtin.indentlines.on_config_done then
    Builtin.indentlines.on_config_done()
  end
end

return M
