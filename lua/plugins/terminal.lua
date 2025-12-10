local M = {}

---@return {width: number, height: number}
local function get_buf_size()
  local cbuf = vim.api.nvim_get_current_buf()
  local bufinfo = vim.tbl_filter(function(buf)
    return buf.bufnr == cbuf
  end, vim.fn.getwininfo(vim.api.nvim_get_current_win()))[1]
  if bufinfo == nil then
    return { width = -1, height = -1 }
  end
  return { width = bufinfo.width, height = bufinfo.height }
end

---@param direction string|number
---@param size number
---@return integer
local function get_dynamic_terminal_size(direction, size)
  size = size or 20
  if direction ~= "float" and tostring(size):find(".", 1, true) then
    size = math.min(size, 1.0)
    local buf_sizes = get_buf_size()
    local buf_size = direction == "horizontal" and buf_sizes.height or buf_sizes.width
    return buf_size * size
  else
    return size
  end
end

M.init = function()
  local execs = {
    { nil, "<M-1>", "Horizontal Terminal", "horizontal", 0.3 },
    { nil, "<M-2>", "Vertical Terminal",   "vertical",   0.4 },
    { nil, "<M-3>", "Float Terminal",      "float",      nil },
  }
  for i, exec in pairs(execs) do
    local direction = exec[4] or "float"

    local opts = {
      cmd = exec[1] or vim.o.shell,
      keymap = exec[2],
      label = exec[3],
      count = i + 100,
      direction = direction,
      size = function()
        return get_dynamic_terminal_size(direction, exec[5])
      end,
    }

    M.add_exec(opts)
  end
end

M.setup = function()
  local terminal = require "toggleterm"
  terminal.setup({
    active = true,
    on_config_done = nil,
    size = 20,
    open_mapping = [[<c-\>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,     -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = false,
    direction = "float",
    close_on_exit = true, -- close the terminal window when the process exits
    shell = nil,          -- change the default shell
    float_opts = {
      border = "curved",
      winblend = 0,
      highlights = {
        border = "Normal",
        background = "Normal",
      },
    },
  })
end

M.add_exec = function(opts)
  local binary = opts.cmd:match "(%S+)"
  if vim.fn.executable(binary) ~= 1 then
    return
  end

  vim.keymap.set({ "n", "t" }, opts.keymap, function()
    M._exec_toggle { cmd = opts.cmd, count = opts.count, direction = opts.direction, size = opts.size() }
  end, { desc = opts.label, noremap = true, silent = true })
end

M._exec_toggle = function(opts)
  local Terminal = require("toggleterm.terminal").Terminal
  local term = Terminal:new { cmd = opts.cmd, count = opts.count, direction = opts.direction }
  term:toggle(opts.size, opts.direction)
end

---@param logfile string the fullpath to the logfile
M.toggle_log_view = function(logfile)
  local log_viewer = "less +F"
  log_viewer = log_viewer .. " " .. logfile
  local term_opts = {
    active = true,
    on_config_done = nil,
    hide_numbers = true, -- hide the number column in toggleterm buffers
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 2,     -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = false,
    close_on_exit = true,   -- close the terminal window when the process exits
    shell = nil,            -- change the default shell
    cmd = log_viewer,
    open_mapping = "",
    direction = "horizontal",
    size = 40,
    float_opts = {},
  }

  local Terminal = require("toggleterm.terminal").Terminal
  local log_view = Terminal:new(term_opts)
  log_view:toggle()
end

M.lazygit_toggle = function()
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new {
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
    },
    on_open = function(_)
      vim.cmd "startinsert!"
    end,
    on_close = function(_) end,
    count = 99,
  }
  lazygit:toggle()
end

function M.get_plugin_config()
  return {
    {
      "akinsho/toggleterm.nvim",
      branch = "main",
      init = M.init,
      config = M.setup,
      cmd = {
        "ToggleTerm",
        "TermExec",
        "ToggleTermToggleAll",
        "ToggleTermSendCurrentLine",
        "ToggleTermSendVisualLines",
        "ToggleTermSendVisualSelection",
      },
    }
  }
end

return M
