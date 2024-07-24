local M = {}

M.setup = function()
  local gitsigns = require "gitsigns"

  gitsigns.setup({
    signs = {
      add = {
        text = Icons.ui.BoldLineLeft
      },
      change = {
        text = Icons.ui.BoldLineLeft
      },
      delete = {
        text = Icons.ui.Triangle
      },
      topdelete = {
        text = Icons.ui.Triangle
      },
      changedelete = {
        text = Icons.ui.BoldLineLeft
      },
    },
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = false,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = true,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    sign_priority = 6,
    status_formatter = nil, -- Use default
    update_debounce = 200,
    max_file_length = 40000,
    preview_config = {
      -- Options passed to nvim_open_win
      border = "rounded",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
  })
end

function M.get_plugin_config()
  return {
    {
      "lewis6991/gitsigns.nvim",
      config = M.setup,
      event = "User FileOpened",
      cmd = "Gitsigns",
    },
  }
end

return M
