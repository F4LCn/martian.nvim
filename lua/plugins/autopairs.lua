local M = {}

local Log = require("core.log")

M.setup = function()
  local status_ok, autopairs = pcall(require, "nvim-autopairs")
  if not status_ok then
    Log:error "Couldn't require autopairs"
    return
  end

  autopairs.setup {
    check_ts = true,
    enable_check_bracket_line = false,
    ts_config = {
      lua = { "string", "source" },
      javascript = { "string", "template_string" },
      java = false,
    },
    disable_in_macro = false,
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
    map_bs = true,
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
      offset = 0,
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  }

  pcall(function()
    local function on_confirm_done(...)
      require("nvim-autopairs.completion.cmp").on_confirm_done()(...)
    end
    require("cmp").event:off("confirm_done", on_confirm_done)
    require("cmp").event:on("confirm_done", on_confirm_done)
  end)
end

function M.get_plugin_config()
  return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = M.setup,
    dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
  }
end

return M
