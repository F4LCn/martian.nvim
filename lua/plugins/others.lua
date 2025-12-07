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
      -- "folke/trouble.nvim",
      "h-michael/trouble.nvim",
      branch = "fix/decoration-provider-api",
      cmd = "Trouble",
      opts = {
        auto_preview = false,
        auto_close = true,
        auto_refresh = true,
        focus = true,
        follow = false,
        preview = {
          type = "split",
          relative = "win",
          position = "right",
          size = 0.5,
          scratch = true,
        },
        modes = {
          symbols = {
            mode = "lsp_document_symbols",
            focus = true,
            auto_refresh = true,
            preview = {
              type = "main",
            },
          },
          references = {
            mode = "lsp_references",
            focus = true,
            auto_refresh = false,
          }
        }
      },
    },
    {
      "Pocco81/auto-save.nvim",
      config = function()
        require("auto-save").setup({
          execution_message = {
            message = function() -- message to print on save
              return ("Auto-saved")
            end,
            dim = 0.18,               -- dim the color of `message`
            cleaning_interval = 1250, -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
          },
        })
      end
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
    {
      "ledger/vim-ledger"
    },
  }
end

return M
