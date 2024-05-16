local M = {}

M.setup = function()
  local status_ok, illuminate = pcall(require, "illuminate")
  if not status_ok then
    return
  end

  local config_ok, _ = pcall(illuminate.configure, {
    providers = {
      "lsp",
      "treesitter",
      "regex",
    },
    delay = 120,
    filetype_overrides = {},
    filetypes_denylist = {
      "dirvish",
      "fugitive",
      "alpha",
      "NvimTree",
      "lazy",
      "neogitstatus",
      "Trouble",
      "lir",
      "Outline",
      "spectre_panel",
      "toggleterm",
      "DressingSelect",
      "TelescopePrompt",
    },
    filetypes_allowlist = {},
    modes_denylist = {},
    modes_allowlist = {},
    providers_regex_syntax_denylist = {},
    providers_regex_syntax_allowlist = {},
    under_cursor = false,
  })
  if not config_ok then
    return
  end
end

function M.get_plugin_config()
  return {
    {
      "RRethy/vim-illuminate",
      config = M.setup,
      event = "User FileOpened",
    },
  }
end

return M
