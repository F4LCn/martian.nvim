local M = {}

function M.setup()
  local previewers = require "telescope.previewers"
  local sorters = require "telescope.sorters"
  local telescope = require "telescope"
  local actions = require "telescope.actions"

  local defaults = {
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
        results_width = 0.8,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob=!.git/",
    },
    mappings = {
      i = {
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-c>"] = false,
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
        ["<C-q>"] = function(...)
          actions.smart_send_to_qflist(...)
          actions.open_qflist(...)
        end,
        ["<CR>"] = actions.select_drop,
        ["<C-f>"] = actions.to_fuzzy_refine,
      },
      n = {
        ["<CR>"] = actions.select_drop,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-q>"] = function(...)
          actions.smart_send_to_qflist(...)
          actions.open_qflist(...)
        end,
      },
    },
    file_ignore_patterns = {},
    path_display = { "smart" },
    winblend = 0,
    border = {},
    borderchars = nil,
    color_devicons = true,
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
  }

  local theme = require("telescope.themes")["get_ivy"]
  if theme then
    defaults = theme(defaults)
  end

  local fzy_opts = {
    fuzzy = true,                   -- false will only do exact matching
    override_generic_sorter = true, -- override the generic sorter
    override_file_sorter = true,    -- override the file sorter
    case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
  }

  ---@diagnostic disable-next-line: redundant-parameter
  telescope.setup({
    active = true,
    on_config_done = nil,
    theme = "ivy",
    defaults = defaults,
    pickers = {
      find_files = {
        hidden = true,
      },
      live_grep = {
        only_sort_text = true,
      },
      grep_string = {
        only_sort_text = true,
      },
      buffers = {
        initial_mode = "normal",
        mappings = {
          i = {
            ["<CR>"] = actions.select_drop,
            ["<C-d>"] = actions.delete_buffer,
          },
          n = {
            ["<CR>"] = actions.select_drop,
            ["dd"] = actions.delete_buffer,
          },
        },
      },
      planets = {
        show_pluto = true,
        show_moon = true,
      },
      git_files = {
        hidden = true,
        show_untracked = true,
        mappings = {
          i = { ["<CR>"] = actions.select_drop },
          n = { ["<CR>"] = actions.select_drop },
        },
      },
      colorscheme = {
        enable_preview = true,
      },
      lsp_dynamic_workspace_symbols = {
        sorter = telescope.extensions.fzy_native.native_fzy_sorter(fzy_opts),
        mappings = {
          i = { ["<CR>"] = actions.select_drop },
          n = { ["<CR>"] = actions.select_drop },
        },
      }
    },
    extensions = {
      fzy_native = fzy_opts,
    },
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    file_sorter = sorters.get_fuzzy_file,
    generic_sorter = sorters.get_generic_fuzzy_sorter,
  })

  pcall(function()
    require("telescope").load_extension "projects"
  end)

  pcall(function()
    require("telescope").load_extension "fzy_native"
  end)
end

function M.get_plugin_config()
  return {
    {
      "nvim-telescope/telescope.nvim",
      -- branch = "0.1.x",
      config = M.setup,
      dependencies = { "telescope-fzy-native.nvim" },
      lazy = true,
      cmd = "Telescope",
    },
    { "nvim-telescope/telescope-fzy-native.nvim", lazy = true },
  }
end

return M
