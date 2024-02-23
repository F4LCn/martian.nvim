-- TODO: move these to individual files

local M = {}
function M.get_plugin_config()
  return {
    "F4LCn/oxocharcoal.nvim",
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'tpope/vim-sleuth',
    { "Tastyep/structlog.nvim", lazy = true },
    { "nvim-lua/plenary.nvim",  cmd = { "PlenaryBustedFile", "PlenaryBustedDirectory" }, lazy = true },
    {
      "nvim-tree/nvim-web-devicons",
      enabled = true,
      lazy = true,
    },
    {
      "b0o/schemastore.nvim",
      lazy = true,
    },
    {
      "lunarvim/bigfile.nvim",
      config = function()
        pcall(function()
          require("bigfile").config({})
        end)
      end,
      enabled = true,
      event = { "FileReadPre", "BufReadPre", "User FileOpened" },
    },
    {
      "windwp/nvim-spectre",
      event = "BufRead",
      config = function()
        require("spectre").setup()
      end,
    },
    {
      "folke/trouble.nvim",
      cmd = "TroubleToggle",
    },
    "tpope/vim-surround",
    {
      "Pocco81/auto-save.nvim",
      config = function()
        require("auto-save").setup()
      end
    },
    "mg979/vim-visual-multi",
    {
      "casonadams/simple-diagnostics.nvim",
      config = function()
        require("simple-diagnostics").setup({
          virtual_text = false,
          message_area = true,
          signs = true,
        })
      end,
    },
    {
      "ray-x/lsp_signature.nvim",
      event = "VeryLazy",
      opts = {},
      config = function(_, opts) require 'lsp_signature'.setup(opts) end
    },
    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {}
    },
    {
      "rktjmp/hotpot.nvim",
      config = function ()
        require("hotpot").setup()
      end
    }
  }
end

return M
