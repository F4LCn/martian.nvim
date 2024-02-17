local M = {}

local builtins = {
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
  "core.theme",
  "core.treesitter",
  "core.which-key",
}

function M.config(config)
  for _, builtin_path in ipairs(builtins) do
    local builtin = require(builtin_path)
    builtin.config(config)
  end
end

return M
