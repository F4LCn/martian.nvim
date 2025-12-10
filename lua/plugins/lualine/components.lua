local colors = require "plugins.lualine.colors"

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

local branch = Icons.git.Branch

return {
  mode = {
    function()
      return " " .. Icons.ui.Target .. " "
    end,
    padding = { left = 0, right = 0 },
    color = {},
    cond = nil,
  },
  branch = {
    "b:gitsigns_head",
    icon = branch,
    color = { gui = "bold" },
  },
  filename = {
    "filename",
    color = {},
    cond = nil,
  },
  diff = {
    "diff",
    source = diff_source,
    symbols = {
      added = Icons.git.LineAdded .. " ",
      modified = Icons.git.LineModified .. " ",
      removed = Icons.git.LineRemoved .. " ",
    },
    padding = { left = 2, right = 1 },
    diff_color = {
      added = { fg = colors.green },
      modified = { fg = colors.yellow },
      removed = { fg = colors.red },
    },
    cond = nil,
  },
  python_env = {
    function()
      local utils = require "plugins.lualine.utils"
      if vim.bo.filetype == "python" then
        local venv = os.getenv "CONDA_DEFAULT_ENV" or os.getenv "VIRTUAL_ENV"
        if venv then
          local icons = require "nvim-web-devicons"
          local py_icon, _ = Icons.get_icon ".py"
          return string.format(" " .. py_icon .. " (%s)", utils.env_cleanup(venv))
        end
      end
      return ""
    end,
    color = { fg = colors.green },
  },
  diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = {
      error = Icons.diagnostics.BoldError .. " ",
      warn = Icons.diagnostics.BoldWarning .. " ",
      info = Icons.diagnostics.BoldInformation .. " ",
      hint = Icons.diagnostics.BoldHint .. " ",
    },
  },
  treesitter = {
    function()
      return Icons.ui.Tree
    end,
    color = function()
      local buf = vim.api.nvim_get_current_buf()
      local ts = vim.treesitter.highlighter.active[buf]
      return { fg = ts and not vim.tbl_isempty(ts) and colors.green or colors.red }
    end,
  },
  lsp = {
    function()
      local buf_clients = vim.lsp.get_clients { bufnr = 0 }
      if #buf_clients == 0 then
        return "LSP Inactive"
      end

      local buf_ft = vim.bo.filetype
      local buf_client_names = {}

      for _, client in pairs(buf_clients) do
        if client.name ~= "null-ls" and client.name ~= "copilot" then
          table.insert(buf_client_names, client.name)
        end
      end



      local unique_client_names = table.concat(buf_client_names, ", ")
      local language_servers = string.format("[%s]", unique_client_names)

      return language_servers
    end,
    color = { gui = "bold" },
  },
  location = { "location" },
  progress = {
    "progress",
    fmt = function()
      return "%P/%L"
    end,
    color = {},
  },

   spaces = {
     function()
       local shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = 0 })
       return Icons.ui.Tab .. " " .. shiftwidth
     end,
     padding = 1,
   },
   ai = {
     function()
       local ai_state = require "utils.ai_state"
       if ai_state.is_enabled() then
         return Icons.ai.Robot
       end
       return ""
     end,
     padding = { left = 1, right = 1 },
     color = function()
       local ai_state = require "utils.ai_state"
       if ai_state.is_enabled() then
         return { fg = colors.green }
       end
       return { fg = colors.gray }
     end,
   },
   encoding = {
     "o:encoding",
     fmt = string.upper,
     color = {},
   },
  filetype = { "filetype", cond = nil, padding = { left = 1, right = 1 } },
  scrollbar = {
    function()
      local current_line = vim.fn.line "."
      local total_lines = vim.fn.line "$"
      local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
      local line_ratio = current_line / total_lines
      local index = math.ceil(line_ratio * #chars)
      return chars[index]
    end,
    padding = { left = 0, right = 0 },
    color = "SLProgress",
    cond = nil,
  },
}
