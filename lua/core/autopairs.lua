local M = {}

function M.config()
  Builtin.autopairs = {
    active = true,
    on_config_done = nil,
    ---@usage  modifies the function or method delimiter by filetypes
    map_char = {
      all = "(",
      tex = "{",
    },
    ---@usage check bracket in same line
    enable_check_bracket_line = false,
    ---@usage check treesitter
    check_ts = true,
    ts_config = {
      lua = { "string", "source" },
      javascript = { "string", "template_string" },
      java = false,
    },
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
    ---@usage disable when recording or executing a macro
    disable_in_macro = false,
    ---@usage map the <BS> key
    map_bs = true,
    ---@usage  change default fast_wrap
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
      offset = 0, -- Offset from pattern match
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  }
end

M.setup = function()
  local status_ok, autopairs = pcall(require, "nvim-autopairs")
  if not status_ok then
    return
  end

  autopairs.setup {
    check_ts = Builtin.autopairs.check_ts,
    enable_check_bracket_line = Builtin.autopairs.enable_check_bracket_line,
    ts_config = Builtin.autopairs.ts_config,
    disable_filetype = Builtin.autopairs.disable_filetype,
    disable_in_macro = Builtin.autopairs.disable_in_macro,
    ignored_next_char = Builtin.autopairs.ignored_next_char,
    enable_moveright = Builtin.autopairs.enable_moveright,
    enable_afterquote = Builtin.autopairs.enable_afterquote,
    map_c_w = Builtin.autopairs.map_c_w,
    map_bs = Builtin.autopairs.map_bs,
    disable_in_visualblock = Builtin.autopairs.disable_in_visualblock,
    fast_wrap = Builtin.autopairs.fast_wrap,
  }

  if Builtin.autopairs.on_config_done then
    Builtin.autopairs.on_config_done(autopairs)
  end

  pcall(function()
    local function on_confirm_done(...)
      require("nvim-autopairs.completion.cmp").on_confirm_done()(...)
    end
    require("cmp").event:off("confirm_done", on_confirm_done)
    require("cmp").event:on("confirm_done", on_confirm_done)
  end)
end

return M
