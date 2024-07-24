local M = {}

local modules = {
  "plugins.theme",
  "plugins.alpha",
  "plugins.which-key",
  "plugins.mini",
  "plugins.treesitter",
  "plugins.autopairs",
  "plugins.breadcrumbs",
  "plugins.comment",
  "plugins.dap",
  "plugins.gitsigns",
  "plugins.illuminate",
  "plugins.lir",
  "plugins.lualine",
  "plugins.telescope",
  "plugins.mason",
  "plugins.nvimtree",
  "plugins.project",
  "plugins.terminal",
  "plugins.others",
  "plugins.bufferline",
  "plugins.indentlines",
  "plugins.neotest",
  -- "plugins.dressing",
  "plugins.neodim",
  "plugins.cmp",
  "lsp",
}

function M:configs()
  local configs = {}
  for _, module_path in ipairs(modules) do
    local module_ok, module = pcall(require, module_path)
    if not module_ok then

      -- use this for debug as it give a clearer error message
      -- module_ok, module = require(module_path)

      vim.notify("Couldn't load " .. module_path)
      goto continue
    end
    local module_config = module.get_plugin_config()
    vim.list_extend(configs, module_config)
    ::continue::
  end
  return configs
end

return M
