local M = {}
local Log = require("core.log")

local function is_ft(b, ft)
  return vim.bo[b].filetype == ft
end

local function diagnostics_indicator(num, _, diagnostics, _)
  local result = {}
  local symbols = {
    error = Icons.diagnostics.Error,
    warning = Icons.diagnostics.Warning,
    info = Icons.diagnostics.Information,
  }
  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. " " .. count)
    end
  end
  result = table.concat(result, " ")
  return #result > 0 and result or ""
end

local function custom_filter(buf, buf_nums)
  local logs = vim.tbl_filter(function(b)
    return is_ft(b, "log")
  end, buf_nums or {})
  if vim.tbl_isempty(logs) then
    return true
  end
  local tab_num = vim.fn.tabpagenr()
  local last_tab = vim.fn.tabpagenr "$"
  local is_log = is_ft(buf, "log")
  if last_tab == 1 then
    return true
  end
  -- only show log buffers in secondary tabs
  return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
end

function M.buf_kill(kill_command, bufnr, force)
  kill_command = kill_command or "bd"

  local bo = vim.bo
  local api = vim.api
  local fmt = string.format
  local fn = vim.fn

  if bufnr == 0 or bufnr == nil then
    bufnr = api.nvim_get_current_buf()
  end

  local bufname = api.nvim_buf_get_name(bufnr)

  if not force then
    local choice
    if bo[bufnr].modified then
      choice = fn.confirm(fmt([[Save changes to "%s"?]], bufname), "&Yes\n&No\n&Cancel")
      if choice == 1 then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("w")
        end)
      elseif choice == 2 then
        force = true
      else
        return
      end
    elseif api.nvim_get_option_value("buftype", { buf = bufnr }) == "terminal" then
      choice = fn.confirm(fmt([[Close "%s"?]], bufname), "&Yes\n&No\n&Cancel")
      if choice == 1 then
        force = true
      else
        return
      end
    end
  end

  -- Get list of windows IDs with the buffer to close
  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, api.nvim_list_wins())

  if force then
    kill_command = kill_command .. "!"
  end

  -- Get list of active buffers
  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and bo[buf].buflisted
  end, api.nvim_list_bufs())

  -- If there is only one buffer (which has to be the current one), vim will
  -- create a new buffer on :bd.
  -- For more than one buffer, pick the previous buffer (wrapping around if necessary)
  if #buffers > 1 and #windows > 0 then
    for i, v in ipairs(buffers) do
      if v == bufnr then
        local prev_buf_idx = i == 1 and #buffers or (i - 1)
        local prev_buffer = buffers[prev_buf_idx]
        for _, win in ipairs(windows) do
          api.nvim_win_set_buf(win, prev_buffer)
        end
      end
    end
  end

  -- Check if buffer still exists, to ensure the target buffer wasn't killed
  -- due to options like bufhidden=wipe.
  if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
    vim.cmd(string.format("%s %d", kill_command, bufnr))
  end
end

function M.setup()
  local status_ok, bufferline = pcall(require, "bufferline")
  if not status_ok then
    Log:error "Could not require bufferline"
    return
  end

  vim.opt.showtabline = 2

  bufferline.setup({
    options = {
      mode = "buffers",
      numbers = "none",
      close_command = function(bufnr)
        M.buf_kill("bd", bufnr, false)
      end,
      indicator = {
        icon = Icons.ui.BoldLineLeft,
        style = "icon",
      },
      modified_icon = Icons.ui.Circle,
      close_icon = Icons.ui.BoldClose,
      left_trunc_marker = Icons.ui.ArrowCircleLeft,
      right_trunc_marker = Icons.ui.ArrowCircleRight,
      -- name_formatter = function(buf)
      --   if buf.name:match "%.md" then
      --     return vim.fn.fnamemodify(buf.name, ":t:r")
      --   end
      -- end,
      max_name_length = 30,
      max_prefix_length = 5,
      truncate_names = true,
      tab_size = 20,
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
      diagnostics_indicator = diagnostics_indicator,
      custom_filter = custom_filter,
      offsets = {
        {
          filetype = "undotree",
          text = "Undotree",
          highlight = "PanelHeading",
          padding = 1,
        },
        {
          filetype = "NvimTree",
          text = "Explorer",
          highlight = "PanelHeading",
          padding = 1,
        },
        {
          filetype = "DiffviewFiles",
          text = "Diff View",
          highlight = "PanelHeading",
          padding = 1,
        },
        {
          filetype = "flutterToolsOutline",
          text = "Flutter Outline",
          highlight = "PanelHeading",
        },
        {
          filetype = "lazy",
          text = "Lazy",
          highlight = "PanelHeading",
          padding = 1,
        },
      },
      color_icons = true,
      show_buffer_icons = false,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = false,
      persist_buffer_sort = true,
      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = false,
      hover = {
        enabled = false,
        delay = 200,
        reveal = { "close" },
      },
      sort_by = "insert_after_current",
    },
    highlights = {
      background = {
        italic = false,
      },
      buffer_selected = {
        bold = false,
      },
    },
  })
end

function M.get_plugin_config()
  return {
    {
      "akinsho/bufferline.nvim",
      config = M.setup,
      version = "*",
      dependencies = 'nvim-tree/nvim-web-devicons',
      event = "User FileOpened",
    }
  }
end

return M
