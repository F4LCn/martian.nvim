local M = {}

M.config = function()
  Builtin.gitsigns = {
    active = true,
    on_config_done = nil,
    opts = {
      signs = {
        add = {
          hl = "GitSignsAdd",
          text = Icons.ui.BoldLineLeft,
          numhl = "GitSignsAddNr",
          linehl = "GitSignsAddLn",
        },
        change = {
          hl = "GitSignsChange",
          text = Icons.ui.BoldLineLeft,
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
        },
        delete = {
          hl = "GitSignsDelete",
          text = Icons.ui.Triangle,
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn",
        },
        topdelete = {
          hl = "GitSignsDelete",
          text = Icons.ui.Triangle,
          numhl = "GitSignsDeleteNr",
          linehl = "GitSignsDeleteLn",
        },
        changedelete = {
          hl = "GitSignsChange",
          text = Icons.ui.BoldLineLeft,
          numhl = "GitSignsChangeNr",
          linehl = "GitSignsChangeLn",
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
        virt_text = true,
        virt_text_pos = "overlay", -- 'eol' | 'overlay' | 'right_align'
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
      yadm = { enable = false },
    },
  }
end

M.setup = function()
  local gitsigns = reload "gitsigns"

  gitsigns.setup(Builtin.gitsigns.opts)
  if Builtin.gitsigns.on_config_done then
    Builtin.gitsigns.on_config_done(gitsigns)
  end
end

return M
