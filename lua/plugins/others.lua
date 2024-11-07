-- TODO: move these to individual files

local M = {}
function M.get_plugin_config()
  return {
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',
    'tpope/vim-sleuth',
    'tpope/vim-abolish',
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
      cmd = "Trouble",
      opts = {
        focus = true,
        follow = true,
        preview = {
          type = "split",
          relative = "win",
          position = "right",
          size = 0.5,
        },
      },
    },
    -- NOTE: disabled in favor of mini.surround
    -- to remove if not used anymore
    -- "tpope/vim-surround",
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
      opts = {
        signs = false,
        keywords = {
          TODO = { color = "hint" },
          NOTE = { color = "info" },
        },
        highlight = {
          before = "fg",
          keyword = "wide_bg",
        },
      }
    },
    {
      "rktjmp/hotpot.nvim",
      config = function()
        require("hotpot").setup()
      end,
      ft = { 'fennel' }
    },
    {
      'mrjones2014/smart-splits.nvim',
      lazy = false,
      opts = {
        at_edge = 'stop',
      },
    },
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {},
    },
  }
end

return M
