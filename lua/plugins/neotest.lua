local M = {}

function M.setup()
  local ok, neotest = pcall(require, "neotest")
  if not ok then
    return
  end
  local adapters = {}
  pcall(function()
    local np_ok, np = pcall(require, "neotest-python")
    if np_ok then
      table.insert(adapters, np({ dap = { justMyCode = false } }))
    end
  end)
  pcall(function()
    local nd_ok, nd = pcall(require, "neotest-dotnet")
    if nd_ok then
      table.insert(adapters, nd)
    end
  end)
  pcall(function()
    local nz_ok, nz = pcall(require, "neotest-zig")
    if nz_ok then
      table.insert(adapters, nz)
    end
  end)

  neotest.setup({ adapters = adapters })
end

function M.get_plugin_config()
  return {
    {
      "nvim-neotest/neotest",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-treesitter/nvim-treesitter"
      },
      config = M.setup,
      lazy = "VeryLazy",
    },
    {
      "nvim-neotest/neotest-python",
      ft = { 'python' }
    },
    {
      "Issafalcon/neotest-dotnet",
      ft = { 'csharp' }
    },
    {
      "lawrence-laz/neotest-zig",
      ft = { 'zig' }
    },
  }
end

return M
