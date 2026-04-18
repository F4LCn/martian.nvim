local M = {}


local function jump_to_diagnostic(jump_count)
  pcall(vim.api.nvim_del_augroup_by_name, "jump_to_diagnostics_augroup")

  local old_virt_text_config = vim.diagnostic.config().virtual_text
  vim.diagnostic.config {
    virtual_text = false,
    virtual_lines = { current_line = true },
  }

  vim.diagnostic.jump { count = jump_count }
  vim.defer_fn(function()
    vim.api.nvim_create_autocmd("CursorMoved", {
      desc = "User(once): Reset diagnostics virtual lines",
      once = true,
      group = vim.api.nvim_create_augroup("jump_to_diagnostics_augroup", {}),
      callback = function()
        vim.diagnostic.config { virtual_lines = false, virtual_text = old_virt_text_config }
      end,
    })
  end, 1)
end

local generic_opts_any = { noremap = true, silent = true }

local generic_opts = {
  insert_mode = generic_opts_any,
  normal_mode = generic_opts_any,
  visual_mode = generic_opts_any,
  visual_block_mode = generic_opts_any,
  command_mode = generic_opts_any,
  operator_pending_mode = generic_opts_any,
  term_mode = { silent = true },
}

local mode_adapters = {
  insert_mode = "i",
  normal_mode = "n",
  term_mode = "t",
  visual_mode = "v",
  visual_block_mode = "x",
  command_mode = "c",
  operator_pending_mode = "o",
}

local keymap = {
  insert_mode = {
    ["<C-c>"] = "<Esc>",
  },

  normal_mode = {
    ["<C-h>"] = "<cmd>lua require('smart-splits').move_cursor_left()<cr>",
    ["<C-j>"] = "<cmd>lua require('smart-splits').move_cursor_down()<cr>",
    ["<C-k>"] = "<cmd>lua require('smart-splits').move_cursor_up()<cr>",
    ["<C-l>"] = "<cmd>lua require('smart-splits').move_cursor_right()<cr>",

    ["<C-S-h>"] = "<cmd>lua require('smart-splits').resize_left()<cr>",
    ["<C-S-j>"] = "<cmd>lua require('smart-splits').resize_down()<cr>",
    ["<C-S-k>"] = "<cmd>lua require('smart-splits').resize_up()<cr>",
    ["<C-S-l>"] = "<cmd>lua require('smart-splits').resize_right()<cr>",

    ["<A-j>"] = ":m .+1<CR>==",
    ["<A-k>"] = ":m .-2<CR>==",

    ["]q"] = ":cnext<CR>",
    ["[q"] = ":cprev<CR>",
    ["<C-q>"] = ":call QuickFixToggle()<CR>",


    ["<F60>"] = function()
      jump_to_diagnostic(1)
    end,
    ["<F24>"] = function()
      jump_to_diagnostic(-1)
    end,




    ["<Esc>"] = "<cmd> noh <CR>",

    ["<leader>ai"] = function()
      local ai_state = require('utils.ai_state')
      ai_state.toggle()
      local copilot_suggestion = require("copilot.suggestion")
      copilot_suggestion.toggle_auto_trigger()
    end,

  },

  term_mode = {
    ["<C-h>"] = "<C-\\><C-N><C-w>h",
    ["<C-j>"] = "<C-\\><C-N><C-w>j",
    ["<C-k>"] = "<C-\\><C-N><C-w>k",
    ["<C-l>"] = "<C-\\><C-N><C-w>l",
  },

  visual_mode = {
    ["<"] = "<gv",
    [">"] = ">gv",
  },

  visual_block_mode = {
    ["<A-j>"] = ":m '>+1<CR>gv-gv",
    ["<A-k>"] = ":m '<-2<CR>gv-gv",
  },

  command_mode = {
    ["<C-j>"] = { 'pumvisible() ? "\\<C-n>" : "\\<C-j>"', { expr = true, noremap = true } },
    ["<C-k>"] = { 'pumvisible() ? "\\<C-p>" : "\\<C-k>"', { expr = true, noremap = true } },
  },
}

if vim.fn.has "mac" == 1 then
  keymap.normal_mode["<A-Up>"] = keymap.normal_mode["<C-Up>"]
  keymap.normal_mode["<A-Down>"] = keymap.normal_mode["<C-Down>"]
  keymap.normal_mode["<A-Left>"] = keymap.normal_mode["<C-Left>"]
  keymap.normal_mode["<A-Right>"] = keymap.normal_mode["<C-Right>"]
end

-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.clear(keymaps)
  local default = M.get_keymap()
  for mode, mappings in pairs(keymaps) do
    local translated_mode = mode_adapters[mode] and mode_adapters[mode] or mode
    for key, _ in pairs(mappings) do
      if default[mode][key] ~= nil or (default[translated_mode] ~= nil and default[translated_mode][key] ~= nil) then
        pcall(vim.api.nvim_del_keymap, translated_mode, key)
      end
    end
  end
end

-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param key The key of keymap
-- @param val Can be form as a mapping or tuple of mapping and user defined opt
function M.set_keymaps(mode, key, val)
  local opt = generic_opts[mode] or generic_opts_any
  if type(val) == "table" then
    opt = val[2]
    val = val[1]
  end
  if val then
    vim.keymap.set(mode, key, val, opt)
  else
    pcall(vim.api.nvim_del_keymap, mode, key)
  end
end

-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(mode, keymaps)
  mode = mode_adapters[mode] or mode
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
end

-- @param keymaps A list of key mappings for each mode
function M.load(keymaps)
  keymaps = keymaps or {}
  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

function M.load_keymap()
  M.load(M.get_keymap())
  -- register converted which-key leader mappings (migrated from plugins/which-key)
  local normal_wk = {
    ["<leader>w"] = { "<cmd>w!<CR>", { desc = "Save" } },
    ["<leader>/"] = { function() return MiniComment.operator() .. "_" end, { desc = "Comment toggle current line", expr = true } },

    ["<leader>fb"] = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Find in buffer" } },
    ["<leader>ft"] = { "<cmd>Telescope live_grep<cr>", { desc = "Find Text" } },
    ["<leader>fT"] = { "<cmd>Telescope live_grep_args<cr>", { desc = "Find Text (Args)" } },
    ["<leader>fF"] = { "<cmd>Telescope find_files<cr>", { desc = "Find File (All)" } },
    ["<leader>fl"] = { "<cmd>Telescope resume initial_mode=normal<cr>", { desc = "Resume last search" } },
    ["<leader>fm"] = { "<cmd>Telescope man_pages sections={\"ALL\"}<cr>", { desc = "Man Pages" } },
    ["<leader>ff"] = { function() require("plugins.telescope.custom-finders").find_project_files { previewer = false } end, { desc = "Find File (project)" } },
    ["<leader>fg"] = { "<cmd>Telescope find_files<cr>", { desc = "Git Files" } },
    ["<leader>fr"] = { "<cmd>Telescope oldfiles<cr>", { desc = "Open Recent File" } },
    ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", { desc = "Find Help" } },
    ["<leader>fw"] = { "<cmd>Telescope grep_string<cr>", { desc = "Find word" } },
    ["<leader>fW"] = { function()
      local word = vim.fn.expand("<cWORD>")
      require("telescope.builtin").grep_string({ search = word })
    end, { desc = "Find word" } },

    ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code Action" } },
    ["<leader>cf"] = { "<cmd>lua require('lsp.utils').format()<cr>", { desc = "Format" } },
    ["<leader>cq"] = { "<cmd>Telescope quickfix<cr>", { desc = "Telescope Quickfix" } },
    ["<leader>cr"] = { "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" } },
    ["<leader>cS"] = { "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Document Symbols" } },
    ["<leader>cs"] = { "<cmd>Telescope lsp_dynamic_workspace_symbols fname_width=0 symbol_width=0.8<cr>", { desc = "Workspace Symbols" } },
    ["<leader>cd"] = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", { desc = "Buffer Diagnostics" } },
    ["<leader>cD"] = { "<cmd>Telescope diagnostics<cr>", { desc = "Workspace diagnostics" } },
    ["<leader>cl"] = { "<cmd>lua vim.lsp.codelens.run()<cr>", { desc = "CodeLens Action" } },

    ["<leader>gg"] = { "<cmd>lua require 'plugins.terminal'.lazygit_toggle()<cr>", { desc = "Lazygit" } },
    ["<leader>gj"] = { "<cmd>lua require 'gitsigns'.next_hunk({navigation_message = false})<cr>", { desc = "Next Hunk" } },
    ["<leader>gk"] = { "<cmd>lua require 'gitsigns'.prev_hunk({navigation_message = false})<cr>", { desc = "Prev Hunk" } },
    ["<leader>gb"] = { "<cmd>lua require 'gitsigns'.blame_line()<cr>", { desc = "Blame" } },
    ["<leader>gp"] = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", { desc = "Preview Hunk" } },
    ["<leader>gr"] = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", { desc = "Reset Hunk" } },
    ["<leader>gR"] = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", { desc = "Reset Buffer" } },
    ["<leader>go"] = { "<cmd>Telescope git_status<cr>", { desc = "Open changed file" } },
    ["<leader>gB"] = { "<cmd>Telescope git_branches<cr>", { desc = "Checkout branch" } },
    ["<leader>gc"] = { "<cmd>Telescope git_commits<cr>", { desc = "Checkout commit" } },
    ["<leader>gC"] = { "<cmd>Telescope git_bcommits<cr>", { desc = "Checkout commit(for current file)" } },
    ["<leader>gd"] = { "<cmd>Gitsigns diffthis HEAD<cr>", { desc = "Git Diff" } },

    ["<leader>tw"] = { "<cmd>Trouble diagnostics toggle<cr>", { desc = "workspace diagnostics" } },
    ["<leader>td"] = { "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "document diagnostics" } },
    ["<leader>tq"] = { "<cmd>Trouble qflist toggle<cr>", { desc = "quickfix" } },
    ["<leader>tl"] = { "<cmd>Trouble loclist toggle<cr>", { desc = "loclist" } },
    ["<leader>tr"] = { "<cmd>Trouble references toggle<cr>", { desc = "references" } },
    ["<leader>te"] = { "<cmd>Trouble diagnostics toggle filter.severity=vim.diagnostic.severity.ERROR<cr>", { desc = "references" } },
    ["<leader>tc"] = { "<cmd>Trouble todo<cr>", { desc = "comments" } },
    ["<leader>tt"] = { "<cmd>Trouble todo filter = {tag={BUG, FIX, TODO}}<cr>", { desc = "todo" } },
    ["<leader>ts"] = { "<cmd>Trouble symbols toggle pinned=true win.relative=win win.position=right win.size=0.3<cr>", { desc = "symbols" } },


    ["<leader>bj"] = { "<cmd>BufferLinePick<cr>", { desc = "Jump to Buffer" } },
    ["<leader>bf"] = { "<cmd>Telescope buffers previewer=false sort_mru=true ignore_current_buffer=true<cr>", { desc = "Find Buffer" } },
    ["<leader>bF"] = { "<cmd>Telescope buffers previewer=true sort_mru=true<cr>", { desc = "Find Buffer" } },
    ["<leader>bx"] = { function() require("plugins.bufferline").buf_kill "bd" end, { desc = "Close current Buffer" } },
    ["<leader>bk"] = { "<cmd>tabclose<cr>", { desc = "Close current Buffer" } },
    ["<leader>bo"] = { "<cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" } },
    ["<leader>bp"] = { "<cmd>BufferLineTogglePin<CR>", { desc = "Pin/unpin buffer" } },

    ["<leader>Nc"] = { "<cmd>edit " .. vim.call('stdpath', 'config') .. "/init.lua<cr>", { desc = "Edit config.lua" } },
    ["<leader>NC"] = { "<cmd>Telescope colorscheme<cr>", { desc = "Colorscheme" } },

    ["<leader>Pl"] = { "<cmd>Lazy<cr>", { desc = "Lazy" } },
    ["<leader>Pm"] = { "<cmd>Mason<cr>", { desc = "Mason" } },

    ["<leader>ee"] = { "<cmd>NvimTreeToggle<CR>", { desc = "Toggle Explorer" } },
    ["<leader>ef"] = { "<cmd>NvimTreeFocus<CR>", { desc = "Focus Explorer" } },

  }


  local visual_wk = {
    ["<leader>/"] = { function() return MiniComment.operator() end, { desc = "Comment toggle linewise (visual)", expr = true } },
    ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code Action" } },
  }

  for lhs, val in pairs(normal_wk) do
    local rhs, opts = val[1], val[2] or { noremap = true, silent = true }
    vim.keymap.set('n', lhs, rhs, opts)
  end

  for lhs, val in pairs(visual_wk) do
    local rhs, opts = val[1], val[2] or { noremap = true, silent = true }
    vim.keymap.set('v', lhs, rhs, opts)
  end
end

function M.get_keymap()
  return keymap
end

return M
