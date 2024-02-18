local M = {}

function M.config()
  Builtin.nvimtree = {
    active = true,
    on_config_done = nil,
    setup = {
      auto_reload_on_write = false,
      disable_netrw = false,
      hijack_cursor = false,
      hijack_netrw = true,
      hijack_unnamed_buffer_when_opening = false,
      sort_by = "name",
      root_dirs = {},
      prefer_startup_root = false,
      sync_root_with_cwd = true,
      reload_on_bufenter = false,
      respect_buf_cwd = false,
      on_attach = "default",
      select_prompts = false,
      view = {
        adaptive_size = false,
        centralize_selection = true,
        width = 30,
        side = "left",
        preserve_window_proportions = false,
        number = false,
        relativenumber = false,
        signcolumn = "yes",
        float = {
          enable = false,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "editor",
            border = "rounded",
            width = 30,
            height = 30,
            row = 1,
            col = 1,
          },
        },
      },
      renderer = {
        add_trailing = true,
        group_empty = false,
        highlight_git = "icon",
        full_name = false,
        highlight_opened_files = "none",
        root_folder_label = ":t",
        indent_width = 2,
        indent_markers = {
          enable = false,
          inline_arrows = true,
          icons = {
            corner = "└",
            edge = "│",
            item = "│",
            none = " ",
          },
        },
        icons = {
          webdev_colors = true,
          git_placement = "before",
          padding = " ",
          symlink_arrow = " ➛ ",
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
          glyphs = {
            default = Icons.ui.Text,
            symlink = Icons.ui.FileSymlink,
            bookmark = Icons.ui.BookMark,
            folder = {
              arrow_closed = Icons.ui.TriangleShortArrowRight,
              arrow_open = Icons.ui.TriangleShortArrowDown,
              default = Icons.ui.Folder,
              open = Icons.ui.FolderOpen,
              empty = Icons.ui.EmptyFolder,
              empty_open = Icons.ui.EmptyFolderOpen,
              symlink = Icons.ui.FolderSymlink,
              symlink_open = Icons.ui.FolderOpen,
            },
            git = {
              unstaged = Icons.git.FileUnstaged,
              staged = Icons.git.FileStaged,
              unmerged = Icons.git.FileUnmerged,
              renamed = Icons.git.FileRenamed,
              untracked = Icons.git.FileUntracked,
              deleted = Icons.git.FileDeleted,
              ignored = Icons.git.FileIgnored,
            },
          },
        },
        special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
        symlink_destination = true,
      },
      hijack_directories = {
        enable = false,
        auto_open = true,
      },
      update_focused_file = {
        enable = true,
        debounce_delay = 15,
        update_root = true,
        ignore_list = {},
      },
      diagnostics = {
        enable = true,
        show_on_dirs = false,
        show_on_open_dirs = true,
        debounce_delay = 50,
        severity = {
          min = vim.diagnostic.severity.HINT,
          max = vim.diagnostic.severity.ERROR,
        },
        icons = {
          hint = Icons.diagnostics.BoldHint,
          info = Icons.diagnostics.BoldInformation,
          warning = Icons.diagnostics.BoldWarning,
          error = Icons.diagnostics.BoldError,
        },
      },
      filters = {
        dotfiles = false,
        git_clean = false,
        no_buffer = false,
        custom = { "node_modules", "\\.cache" },
        exclude = {},
      },
      filesystem_watchers = {
        enable = true,
        debounce_delay = 50,
        ignore_dirs = {},
      },
      git = {
        enable = true,
        ignore = false,
        show_on_dirs = true,
        show_on_open_dirs = true,
        timeout = 200,
      },
      actions = {
        use_system_clipboard = true,
        change_dir = {
          enable = true,
          global = false,
          restrict_above_cwd = false,
        },
        expand_all = {
          max_folder_discovery = 300,
          exclude = {},
        },
        file_popup = {
          open_win_config = {
            col = 1,
            row = 1,
            relative = "cursor",
            border = "shadow",
            style = "minimal",
          },
        },
        open_file = {
          quit_on_open = false,
          resize_window = false,
          window_picker = {
            enable = true,
            picker = "default",
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
        remove_file = {
          close_window = true,
        },
      },
      trash = {
        cmd = "trash",
        require_confirm = true,
      },
      live_filter = {
        prefix = "[FILTER]: ",
        always_show_folders = true,
      },
      tab = {
        sync = {
          open = false,
          close = false,
          ignore = {},
        },
      },
      notify = {
        threshold = vim.log.levels.INFO,
      },
      log = {
        enable = false,
        truncate = false,
        types = {
          all = false,
          config = false,
          copy_paste = false,
          dev = false,
          diagnostics = false,
          git = false,
          profile = false,
          watcher = false,
        },
      },
      system_open = {
        cmd = nil,
        args = {},
      },
    },
  }
end

function M.start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode] {
    cwd = basedir,
  }
end

local function on_attach(bufnr)
  local api = require "nvim-tree.api"

  local function telescope_find_files(_)
    require("core.nvimtree").start_telescope "find_files"
  end

  local function telescope_live_grep(_)
    require("core.nvimtree").start_telescope "live_grep"
  end

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  api.config.mappings.default_on_attach(bufnr)

  local useful_keys = {
    ["l"] = { api.node.open.edit, opts "Open" },
    ["o"] = { api.node.open.edit, opts "Open" },
    ["<CR>"] = { api.node.open.edit, opts "Open" },
    ["v"] = { api.node.open.vertical, opts "Open: Vertical Split" },
    ["h"] = { api.node.navigate.parent_close, opts "Close Directory" },
    ["C"] = { api.tree.change_root_to_node, opts "CD" },
    ["gtg"] = { telescope_live_grep, opts "Telescope Live Grep" },
    ["gtf"] = { telescope_find_files, opts "Telescope Find File" },
  }

  require("keymaps").load_mode("n", useful_keys)
end

function M.setup()
  local status_ok, nvim_tree = pcall(require, "nvim-tree")

  if not status_ok then
    return
  end

  -- Implicitly update nvim-tree when project module is active
  if Builtin.project.active then
    Builtin.nvimtree.setup.respect_buf_cwd = true
    Builtin.nvimtree.setup.update_cwd = true
    Builtin.nvimtree.setup.update_focused_file.enable = true
    Builtin.nvimtree.setup.update_focused_file.update_cwd = true
  end

  -- Add useful keymaps
  if Builtin.nvimtree.setup.on_attach == "default" then
    Builtin.nvimtree.setup.on_attach = on_attach
  end

  nvim_tree.setup(Builtin.nvimtree.setup)

  if Builtin.nvimtree.on_config_done then
    Builtin.nvimtree.on_config_done(nvim_tree)
  end
end

return M
