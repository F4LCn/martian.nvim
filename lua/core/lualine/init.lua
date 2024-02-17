local M = {}
M.config = function()
  builtin.lualine = {
    active = true,
    options = {
      icons_enabled = nil,
      component_separators = nil,
      section_separators = nil,
      theme = nil,
      disabled_filetypes = { statusline = { "alpha" } },
      globalstatus = true,
    },
    sections = {
      lualine_a = nil,
      lualine_b = nil,
      lualine_c = nil,
      lualine_x = nil,
      lualine_y = nil,
      lualine_z = nil,
    },
    inactive_sections = {
      lualine_a = nil,
      lualine_b = nil,
      lualine_c = nil,
      lualine_x = nil,
      lualine_y = nil,
      lualine_z = nil,
    },
    tabline = nil,
    extensions = nil,
    on_config_done = nil,
  }
end

M.setup = function()
  local status_ok, lualine = pcall(require, "lualine")
  if not status_ok then
    return
  end

  require("core.lualine.styles").update()

  lualine.setup(builtin.lualine)

  if builtin.lualine.on_config_done then
    builtin.lualine.on_config_done(lualine)
  end
end

return M
