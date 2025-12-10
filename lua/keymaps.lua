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


    ["<F5>"] = "<cmd>lua require'dap'.continue()<cr>",
    ["<F9>"] = "<cmd>lua require'dap'.step_back()<cr>",
    ["<F10>"] = "<cmd>lua require'dap'.step_over()<cr>",
    ["<F11>"] = "<cmd>lua require'dap'.step_into()<cr>",
    ["<F12>"] = "<cmd>lua require'dap'.step_out()<cr>",

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
end

function M.get_keymap()
  return keymap
end

return M
