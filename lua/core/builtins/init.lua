local M = {}

local Log = require("core.log")

local builtins = {
  "core.theme",
  "core.alpha",
  "core.autopairs",
  "core.breadcrumbs",
  "core.bufferline",
  "core.cmp",
  "core.comment",
  "core.dap",
  "core.gitsigns",
  "core.illuminate",
  "core.indentlines",
  "core.lir",
  "core.lualine",
  "core.mason",
  "core.nvimtree",
  "core.project",
  "core.telescope",
  "core.terminal",
  "core.treesitter",
  "core.which-key",
}

function M.config(config)
  for _, builtin_path in ipairs(builtins) do
    local builtin_ok, builtin = pcall(require, builtin_path)
    if not builtin_ok then
      print("Couldn't load " .. builtin_path)
    end
    builtin.config(config)
  end
end

return M
