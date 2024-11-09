local M = {}

function _G.get_config_dir()
  return vim.call("stdpath", "config")
end

M.setup = function()
  local which_key = require "which-key"

  ---@diagnostic disable-next-line: redundant-parameter
  which_key.setup({
    plugins = {
      marks = false,          -- shows a list of your marks on ' and `
      registers = false,      -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      presets = {
        operators = false,    -- adds help for operators like d, y, ...
        motions = false,      -- adds help for motions
        text_objects = false, -- help for text objects triggered after entering an operator
        windows = false,      -- default bindings on <c-w>
        nav = false,          -- misc bindings to work with windows
        z = false,            -- bindings for folds, spelling and others prefixed with z
        g = false,            -- bindings for prefixed with g
      },
    },
    icons = {
      breadcrumb = Icons.ui.DoubleChevronRight, -- symbol used in the command line area that shows your active key combo
      separator = Icons.ui.BoldArrowRight,      -- symbol used between a key and it's label
      group = Icons.ui.Plus,                    -- symbol prepended to a group
      mappings = false,
    },
    keys = {
      scroll_down = "<c-d>", -- binding to scroll down inside the popup
      scroll_up = "<c-u>",   -- binding to scroll up inside the popup
    },
    win = {
      border = "single",        -- none, single, double, shadow
      padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    },
    layout = {
      height = { min = 4, max = 25 }, -- min and max height of the columns
      width = { min = 20, max = 50 }, -- min and max width of the columns
      spacing = 3,                    -- spacing between columns
      align = "left",                 -- align columns left, center or right
    },
    show_help = false,                -- show help message on the command line when the popup is visible
    show_keys = false,                -- show the currently pressed key and its label as a message in the command line
    disable = {
      buftypes = {},
      filetypes = { "TelescopePrompt" },
    },
  })

  local normal_mappings = {
    mode = { "n" },
    { "<leader>w",  "<cmd>w!<CR>",                                     desc = "Save" },
    { "<leader>/",  "<Plug>(comment_toggle_linewise_current)",         desc = "Comment toggle current line" },

    { "<leader>f",  group = "Find" },
    { "<leader>ft", "<cmd>Telescope live_grep<cr>",                    desc = "Find Text" },
    { "<leader>fF", "<cmd>Telescope find_files<cr>",                   desc = "Find File (All)" },
    { "<leader>fl", "<cmd>Telescope resume<cr>",                       desc = "Resume last search" },
    { "<leader>fm", "<cmd>Telescope man_pages sections={\"ALL\"}<cr>", desc = "Man Pages" },
    {
      "<leader>ff",
      function()
        require("plugins.telescope.custom-finders").find_project_files { previewer = false }
      end,
      desc = "Find File (project)"
    },
    { "<leader>fg", "<cmd>Telescope find_files<cr>",  desc = "Git Files" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Open Recent File" },
    { "<leader>fh", "<cmd>Telescope help_tags<cr>",   desc = "Find Help" },
    { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Find word" },
    {
      "<leader>fW",
      function()
        local word = vim.fn.expand("<cWORD>")
        require("telescope.builtin").grep_string({ search = word })
      end,
      desc = "Find word"
    },

    { "<leader>c",  group = "Code" },
    { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>",     desc = "Code Action" },
    { "<leader>cf", "<cmd>lua require('lsp.utils').format()<cr>", desc = "Format" },
    { "<leader>cq", "<cmd>Telescope quickfix<cr>",                desc = "Telescope Quickfix" },
    { "<leader>cr", "<cmd>lua vim.lsp.buf.rename()<cr>",          desc = "Rename" },
    { "<leader>cS", "<cmd>Telescope lsp_document_symbols<cr>",    desc = "Document Symbols" },
    {
      "<leader>cs",
      "<cmd>Telescope lsp_dynamic_workspace_symbols fname_width=0 symbol_width=0.8<cr>",
      desc = "Workspace Symbols"
    },
    { "<leader>cd", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>",                    desc = "Buffer Diagnostics" },
    { "<leader>cD", "<cmd>Telescope diagnostics<cr>",                                          desc = "Workspace diagnostics" },
    { "<leader>cl", "<cmd>lua vim.lsp.codelens.run()<cr>",                                     desc = "CodeLens Action" },

    { "<leader>g",  group = "Git" },
    { "<leader>gg", "<cmd>lua require 'plugins.terminal'.lazygit_toggle()<cr>",                desc = "Lazygit", },
    { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", desc = "Next Hunk", },
    { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", desc = "Prev Hunk", },
    { "<leader>gb", "<cmd>lua require 'gitsigns'.blame_line()<cr>",                            desc = "Blame", },
    { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>",                          desc = "Preview Hunk", },
    { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>",                            desc = "Reset Hunk", },
    { "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>",                          desc = "Reset Buffer", },
    { "<leader>go", "<cmd>Telescope git_status<cr>",                                           desc = "Open changed file", },
    { "<leader>gB", "<cmd>Telescope git_branches<cr>",                                         desc = "Checkout branch", },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>",                                          desc = "Checkout commit", },
    {
      "<leader>gC",
      "<cmd>Telescope git_bcommits<cr>",
      desc = "Checkout commit(for current file)",
    },
    {
      "<leader>gd",
      "<cmd>Gitsigns diffthis HEAD<cr>",
      desc = "Git Diff",
    },

    { "<leader>t",  group = "Trouble" },
    { "<leader>tw", "<cmd>Trouble diagnostics toggle<cr>",                                                          desc = "workspace diagnostics" },
    { "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",                                             desc = "document diagnostics" },
    { "<leader>tq", "<cmd>Trouble qflist toggle<cr>",                                                               desc = "quickfix" },
    { "<leader>tl", "<cmd>Trouble loclist toggle<cr>",                                                              desc = "loclist" },
    { "<leader>tr", "<cmd>Trouble references toggle<cr>",                                                           desc = "references" },
    { "<leader>te", "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>",            desc = "references" },
    { "<leader>tt", "<cmd>TodoTrouble<cr>",                                                                         desc = "todos" },
    { "<leader>ts", "<cmd>Trouble symbols toggle pinned=true win.relative=win win.position=right win.size=0.3<cr>", desc = "symbols" },

    { "<leader>d",  group = "Debug" },
    { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",                                                desc = "Toggle Breakpoint" },
    { "<leader>dC", "<cmd>lua require'dap'.run_to_cursor()<cr>",                                                    desc = "Run To Cursor" },
    { "<leader>dg", "<cmd>lua require'dap'.session()<cr>",                                                          desc = "Get Session" },
    { "<leader>dp", "<cmd>lua require'dap'.pause()<cr>",                                                            desc = "Pause" },
    { "<leader>ds", "<cmd>lua require'dap'.continue()<cr>",                                                         desc = "Start" },
    { "<leader>dq", "<cmd>lua require'dap'.close()<cr>",                                                            desc = "Quit" },
    { "<leader>dd", "<cmd>lua require'dapui'.toggle({reset = true})<cr>",                                           desc = "Toggle UI" },

    { "<leader>b",  group = "buffer" },
    { "<leader>bj", "<cmd>BufferLinePick<cr>",                                                                      desc = "Jump to Buffer" },
    { "<leader>bf", "<cmd>Telescope buffers previewer=false sort_mru=true ignore_current_buffer=true<cr>",          desc = "Find Buffer" },
    {
      "<leader>bx",
      function()
        require("plugins.bufferline").buf_kill "bd"
      end
      ,
      desc = "Close current Buffer"
    },
    { "<leader>bk", "<cmd>tabclose<cr>",              desc = "Close current Buffer" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
    { "<leader>bp", "<cmd>BufferLineTogglePin<CR>",   desc = "Pin/unpin buffer" },

    { "<leader>N",  group = "Neovim" },
    {
      "<leader>Nc",
      "<cmd>edit " .. get_config_dir() .. "/init.lua<cr>",
      desc = "Edit config.lua",
    },
    { "<leader>NC", "<cmd>Telescope colorscheme<cr>", desc = "Colorscheme" },

    { "<leader>P",  group = "Plugins" },
    { "<leader>Pl", "<cmd>Lazy<cr>",                  desc = "Lazy" },
    { "<leader>Pm", "<cmd>Mason<cr>",                 desc = "Mason" },

    { "<leader>e",  group = "File Tree" },
    { "<leader>ee", "<cmd>NvimTreeToggle<CR>",        desc = "Toggle Explorer" },
    { "<leader>ef", "<cmd>NvimTreeFocus<CR>",         desc = "Focus Explorer" },
  }

  local visual_mappings = {
    mode = { "v" },
    { "<leader>/",  "<Plug>(comment_toggle_linewise_visual)", desc = "Comment toggle linewise (visual)" },

    { "<leader>c",  group = "Code" },
    { "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
  }

  which_key.add(normal_mappings)
  which_key.add(visual_mappings)
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
