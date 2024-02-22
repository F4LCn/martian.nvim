local M = {}

function get_config_dir()
  return vim.call("stdpath", "config")
end

M.setup = function()
  local which_key = require "which-key"

  ---@diagnostic disable-next-line: redundant-parameter
  which_key.setup({
    plugins = {
      marks = false,     -- shows a list of your marks on ' and `
      registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      spelling = {
        enabled = true,
        suggestions = 20,
      }, -- use which-key for spelling hints
      -- the presets plugin, adds help for a bunch of default keybindings in Neovim
      -- No actual key bindings are created
      presets = {
        operators = false,   -- adds help for operators like d, y, ...
        motions = false,     -- adds help for motions
        text_objects = true, -- help for text objects triggered after entering an operator
        windows = true,      -- default bindings on <c-w>
        nav = true,          -- misc bindings to work with windows
        z = false,           -- bindings for folds, spelling and others prefixed with z
        g = false,           -- bindings for prefixed with g
      },
    },
    -- add operators that will trigger motion and text object completion
    -- to enable all native operators, set the preset / operators plugin above
    operators = { gc = "Comments" },
    key_labels = {
    },
    icons = {
      breadcrumb = Icons.ui.DoubleChevronRight, -- symbol used in the command line area that shows your active key combo
      separator = Icons.ui.BoldArrowRight,      -- symbol used between a key and it's label
      group = Icons.ui.Plus,                    -- symbol prepended to a group
    },
    popup_mappings = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>",   -- binding to scroll up inside the popup
    },
    window = {
      border = "single",        -- none, single, double, shadow
      position = "bottom",      -- bottom, top
      margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
      winblend = 0,
    },
    layout = {
      height = { min = 4, max = 25 },                                             -- min and max height of the columns
      width = { min = 20, max = 50 },                                             -- min and max width of the columns
      spacing = 3,                                                                -- spacing between columns
      align = "left",                                                             -- align columns left, center or right
    },
    ignore_missing = true,                                                        -- enable this to hide mappings for which you didn't specify a label
    hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
    show_help = true,                                                             -- show help message on the command line when the popup is visible
    show_keys = true,                                                             -- show the currently pressed key and its label as a message in the command line
    triggers = "auto",                                                            -- automatically setup triggers
    -- triggers = {"<leader>"} -- or specify a list manually
    triggers_blacklist = {
      i = { "j", "k" },
      v = { "j", "k" },
    },
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  })

  local opts = {
    mode = "n",     -- NORMAL mode
    prefix = "<leader>",
    buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true,  -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true,  -- use `nowait` when creating keymaps
  }
  local vopts = {
    mode = "v",     -- VISUAL mode
    prefix = "<leader>",
    buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
    silent = true,  -- use `silent` when creating keymaps
    noremap = true, -- use `noremap` when creating keymaps
    nowait = true,  -- use `nowait` when creating keymaps
  }

  local mappings = {
    ["w"] = { "<cmd>w!<CR>", "Save" },
    f = {
      name = "Find",
      t = { "<cmd>Telescope live_grep<cr>", "Text" },
      F = { "<cmd>Telescope find_files<cr>", "Find File (All)" },
      l = { "<cmd>Telescope resume<cr>", "Resume last search" },
      m = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
      f = {
        function()
          require("plugins.telescope.custom-finders").find_project_files { previewer = false }
        end,
        "Find File (project)",
      },
      g = { "<cmd>Telescope find_files<cr>", "Git Files" },
      r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
      h = { "<cmd>Telescope help_tags<cr>", "Find Help" },
    },
    c = {
      name = "Code",
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
      f = { "<cmd>lua require('lsp.utils').format()<cr>", "Format" },
      q = { "<cmd>Telescope quickfix<cr>", "Telescope Quickfix" },
      r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
      S = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
      s = {
        "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
        "Workspace Symbols",
      },
      d = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
      D = { "<cmd>Telescope diagnostics<cr>", "Workspace diagnostics" },
      l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    },
    g = {
      name = "Git",
      g = { "<cmd>lua require 'plugins.terminal'.lazygit_toggle()<cr>", "Lazygit" },
      j = { "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", "Next Hunk" },
      k = { "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", "Prev Hunk" },
      b = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", "Blame" },
      p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
      r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
      R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
      o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
      B = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
      c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
      C = {
        "<cmd>Telescope git_bcommits<cr>",
        "Checkout commit(for current file)",
      },
      d = {
        "<cmd>Gitsigns diffthis HEAD<cr>",
        "Git Diff",
      },
    },
    t = {
      name = "Trouble",
      t = { "<cmd>TroubleToggle<cr>", "trouble" },
      w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
      d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
      q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
      l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
      r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
      D = { "<cmd>TodoTrouble<cr>", "todos" },
    },
    d = {
      name = "Debug",
      b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Toggle Breakpoint" },
      C = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run To Cursor" },
      g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
      p = { "<cmd>lua require'dap'.pause()<cr>", "Pause" },
      s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
      q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
      d = { "<cmd>lua require'dapui'.toggle({reset = true})<cr>", "Toggle UI" },
    },
    b = {
      name = "Buffer",
      j = { "<cmd>BufferLinePick<cr>", "Jump" },
      f = { "<cmd>Telescope buffers previewer=false<cr>", "Find" },
      x = {
        function()
          require("plugins.bufferline").buf_kill "bd"
        end
        , "Close Buffer" },
      o = { "<cmd>BufferLineCloseOthers<CR>", "Close all other buffers" },
    },
    N = {
      name = "Nvim",
      c = {
        "<cmd>edit " .. get_config_dir() .. "/init.lua<cr>",
        "Edit config.lua",
      },
      C = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
    },
    P = {
      name = "PLugin",
      l = { "<cmd>Lazy<cr>", "Lazy" },
      m = { "<cmd>Mason<cr>", "Mason" },
    },
    e = {
      name = "Explorer",
      e = { "<cmd>NvimTreeToggle<CR>", "Toggle Explorer" },
      f = { "<cmd>NvimTreeFocus<CR>", "Focus Explorer" },
    },
    ["/"] = { "<Plug>(comment_toggle_linewise_current)", "Comment toggle current line" },
  }
  local vmappings = {
    ["/"] = { "<Plug>(comment_toggle_linewise_visual)", "Comment toggle linewise (visual)" },
    l = {
      name = "LSP",
      a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    },
  }

  which_key.register(mappings, opts)
  which_key.register(vmappings, vopts)
end

function M.get_plugin_config()
  return {
    {
      "folke/which-key.nvim",
      config = M.setup,
      cmd = "WhichKey",
      event = "VeryLazy",
    },
  }
end

return M
