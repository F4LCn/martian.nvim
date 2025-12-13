local M = {}
local Input = require("nui.input")
local Menu = require("nui.menu")

function M.setup()
  vim.ui.input = function(input_opts, on_confirm)
    input_opts = input_opts or {}
    local prompt = input_opts.prompt or "Input: "
    local default = input_opts.default or ""

    local parent_win = vim.api.nvim_get_current_win()
    local mode = vim.fn.mode()

    local input_dialog
    input_dialog = Input({
      relative = "editor",
      position = "50%",
      size = {
        width = 40,
        height = 1,
      },
      border = {
        style = "rounded",
        highlight = "FloatBorder",
        text = {
          top = " " .. prompt .. " ",
          top_align = "left",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    }, {
      prompt = "",
      default_value = default,
      on_close = function()
        on_confirm(nil)
      end,
      on_submit = function(value)
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(parent_win) then
            vim.api.nvim_set_current_win(parent_win)
            if mode == "i" then
              vim.cmd("startinsert")
            end
          end
          on_confirm(value)
        end)
      end,
    })

    input_dialog:map("n", "<Esc>", function()
      on_confirm(nil)
      input_dialog:unmount()
    end, { noremap = true })

    input_dialog:mount()
  end

  vim.ui.select = function(items, select_opts, on_choice)
    select_opts = select_opts or {}
    local prompt = select_opts.prompt or "Select: "
    local format_item = select_opts.format_item or tostring

    local menu_items = {}
    for i, item in ipairs(items) do
      table.insert(menu_items, Menu.item(format_item(item), {data = item, index = i}))
    end
    local parent_win = vim.api.nvim_get_current_win()
    local mode = vim.fn.mode()
    local select_menu = Menu({
      relative = "editor",
      position = "50%",
      size = {
        width = 60,
        height = math.min(#items, 10),
      },
      border = {
        style = "rounded",
        highlight = "FloatBorder",
        text = {
          top = " " .. prompt .. " ",
          top_align = "left",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
      },
    }, {
      lines = menu_items,
      on_close = function()
        on_choice(nil, nil)
      end,
      on_submit = function(item)
        vim.schedule(function()
          on_choice(item.data, item.index)
        end)
      end,
      keymap = {
        close = { "<Esc>", "<C-c>" },
        focus_next = { "j", "<Down>" },
        focus_prev = { "k", "<Up>" },
        submit = { "<CR>" },
      },
    })

    select_menu:mount()
  end
end

return M
