local M = {}
local Log = require("core.log")

local modules = {
  "plugins.theme",
  "plugins.alpha",
  "plugins.autopairs",
  "plugins.breadcrumbs",
  "plugins.bufferline",
  "plugins.cmp",
  "plugins.comment",
  "plugins.dap",
  "plugins.gitsigns",
  "plugins.illuminate",
  "plugins.indentlines",
  "plugins.lir",
  "plugins.lualine",
  "plugins.mason",
  "plugins.nvimtree",
  "plugins.project",
  "plugins.telescope",
  "plugins.terminal",
  "plugins.treesitter",
  "plugins.which-key",
  "plugins.others",
  "lsp",
}

function M:configs()
  local configs = {}
  for _, module_path in ipairs(modules) do
    local module_ok, module = pcall(require, module_path)
    if not module_ok then
      Log:error("Couldn't load " .. module_path)
    end
    local module_config = module.get_plugin_config()
    vim.list_extend(configs, module_config)
  end
  return configs
end

return M
