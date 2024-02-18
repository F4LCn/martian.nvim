local M = {}

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
    [";"] = ":",
    -- Better window movement
    ["<C-h>"] = "<C-w>h",
    ["<C-j>"] = "<C-w>j",
    ["<C-k>"] = "<C-w>k",
    ["<C-l>"] = "<C-w>l",

    -- Resize with arrows
    ["<C-Up>"] = ":resize -2<CR>",
    ["<C-Down>"] = ":resize +2<CR>",
    ["<C-Left>"] = ":vertical resize -2<CR>",
    ["<C-Right>"] = ":vertical resize +2<CR>",

    -- QuickFix
    ["]q"] = ":cnext<CR>",
    ["[q"] = ":cprev<CR>",
    ["<C-q>"] = ":call QuickFixToggle()<CR>",

    -- Diagnostics
    ["<M-F12>"] = "<cmd>lua vim.diagnostic.goto_next()<cr>",
    ["<S-F12>"] = "<cmd>lua vim.diagnostic.goto_prev()<cr>",

    -- tabs navigation
    ["<Tab>"] = ":BufferLineCycleNext<CR>",
    ["<S-Tab>"] = ":BufferLineCyclePrev<CR>",

    -- Debugging
    ["<F5>"] = "<cmd>lua require'dap'.continue()<cr>",
    ["<F9>"] = "<cmd>lua require'dap'.step_back()<cr>",
    ["<F10>"] = "<cmd>lua require'dap'.step_over()<cr>",
    ["<F11>"] = "<cmd>lua require'dap'.step_into()<cr>",
    ["<F12>"] = "<cmd>lua require'dap'.step_out()<cr>",

    -- no highlight on esc
    ["<Esc>"] = "<cmd> noh <CR>",

  },

  term_mode = {
    -- Terminal window navigation
    ["<C-h>"] = "<C-\\><C-N><C-w>h",
    ["<C-j>"] = "<C-\\><C-N><C-w>j",
    ["<C-k>"] = "<C-\\><C-N><C-w>k",
    ["<C-l>"] = "<C-\\><C-N><C-w>l",
  },

  visual_mode = {
    -- Better indenting
    ["<"] = "<gv",
    [">"] = ">gv",
  },

  visual_block_mode = {
  },

  command_mode = {
    -- navigate tab completion with <c-j> and <c-k>
    -- runs conditionally
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

-- Unsets all keybindings defined in keymaps
-- @param keymaps The table of key mappings containing a list per mode (normal_mode, insert_mode, ..)
function M.clear(keymaps)
  local default = M.get_keymap()
  for mode, mappings in pairs(keymaps) do
    local translated_mode = mode_adapters[mode] and mode_adapters[mode] or mode
    for key, _ in pairs(mappings) do
      -- some plugins may override default bindings that the user hasn't manually overriden
      if default[mode][key] ~= nil or (default[translated_mode] ~= nil and default[translated_mode][key] ~= nil) then
        pcall(vim.api.nvim_del_keymap, translated_mode, key)
      end
    end
  end
end

-- Set key mappings individually
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

-- Load key mappings for a given mode
-- @param mode The keymap mode, can be one of the keys of mode_adapters
-- @param keymaps The list of key mappings
function M.load_mode(mode, keymaps)
  mode = mode_adapters[mode] or mode
  for k, v in pairs(keymaps) do
    M.set_keymaps(mode, k, v)
  end
end

-- Load key mappings for all provided modes
-- @param keymaps A list of key mappings for each mode
function M.load(keymaps)
  keymaps = keymaps or {}
  for mode, mapping in pairs(keymaps) do
    M.load_mode(mode, mapping)
  end
end

-- Load the default keymappings
function M.load_keymap()
  M.load(M.get_keymap())
end

-- Get the default keymappings
function M.get_keymap()
  return keymap
end

return M
