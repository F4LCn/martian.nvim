local M = {}

M.config = function()
  local adapters = {

    coreclr = {
      type = 'executable',
      command = '/usr/share/netcoredbg/netcoredbg',
      args = { '--interpreter=vscode' }
    },
    gdb = {
      type = "executable",
      command = "gdb",
      args = { "-i", "dap" }
    },
    codelldb = {
      type = 'server',
      host = '127.0.0.1',
      port = 13000,
      executable = {
        -- CHANGE THIS to your path!
        command = '/root/.local/share/nvim/mason/bin/codelldb',
        args = { "--port", "13000" },
        detached = false,
      }
    }
  }

  local configurations = {}
  configurations.cs = {
    {
      type = "coreclr",
      name = "launch - netcoredbg",
      request = "launch",
      program = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
      end,
    },
  }
  configurations.c = {
    {
      name = "Launch - codelldb",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
    },
  }
  configurations.cpp = configurations.c
  configurations.rust = configurations.c
  configurations["rs"] = configurations.c


  Builtin.dap = {
    active = true,
    on_config_done = nil,
    breakpoint = {
      text = Icons.ui.Bug,
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    },
    breakpoint_rejected = {
      text = Icons.ui.Bug,
      texthl = "DiagnosticSignError",
      linehl = "",
      numhl = "",
    },
    stopped = {
      text = Icons.ui.BoldArrowRight,
      texthl = "DiagnosticSignWarn",
      linehl = "Visual",
      numhl = "DiagnosticSignWarn",
    },
    log = {
      level = "info",
    },
    ui = {
      auto_open = true,
      notify = {
        threshold = vim.log.levels.INFO,
      },
      config = {
        icons = { expanded = "", collapsed = "", circular = "" },
        mappings = {
          -- Use a table to apply multiple mappings
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        -- Use this to override mappings for specific elements
        element_mappings = {},
        expand_lines = true,
        layouts = {
          {
            elements = {
              { id = "scopes",      size = 0.33 },
              { id = "breakpoints", size = 0.17 },
              { id = "stacks",      size = 0.25 },
              { id = "watches",     size = 0.25 },
            },
            size = 0.33,
            position = "right",
          },
          {
            elements = {
              { id = "repl",    size = 0.45 },
              { id = "console", size = 0.55 },
            },
            size = 0.27,
            position = "bottom",
          },
        },
        controls = {
          enabled = true,
          -- Display controls in this element
          element = "repl",
          icons = {
            pause = "",
            play = "",
            step_into = "",
            step_over = "",
            step_out = "",
            step_back = "",
            run_last = "",
            terminate = "",
          },
        },
        floating = {
          max_height = 0.9,
          max_width = 0.5, -- Floats will be treated as percentage of your screen.
          border = "rounded",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        windows = { indent = 1 },
        render = {
          max_type_length = nil, -- Can be integer or nil.
          max_value_lines = 100, -- Can be integer or nil.
        },
      },
    },
    adapters = adapters,
    configurations = configurations,
  }
end

M.setup = function()
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    return
  end

  vim.fn.sign_define("DapBreakpoint", Builtin.dap.breakpoint)
  vim.fn.sign_define("DapBreakpointRejected", Builtin.dap.breakpoint_rejected)
  vim.fn.sign_define("DapStopped", Builtin.dap.stopped)

  dap.set_log_level(Builtin.dap.log.level)

  if Builtin.dap.on_config_done then
    Builtin.dap.on_config_done(dap)
  end
end

M.setup_ui = function()
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    return
  end
  local dapui = require "dapui"
  dapui.setup(Builtin.dap.ui.config)

  if Builtin.dap.ui.auto_open then
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    -- dap.listeners.before.event_terminated["dapui_config"] = function()
    --   dapui.close()
    -- end
    -- dap.listeners.before.event_exited["dapui_config"] = function()
    --   dapui.close()
    -- end
  end

  -- until rcarriga/nvim-dap-ui#164 is fixed
  local function notify_handler(msg, level, opts)
    if level >= Builtin.dap.ui.notify.threshold then
      return vim.notify(msg, level, opts)
    end

    opts = vim.tbl_extend("keep", opts or {}, {
      title = "dap-ui",
      icon = "",
      on_open = function(win)
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = vim.api.nvim_win_get_buf(win) })
      end,
    })
  end

  local _, _ = xpcall(function()
    require("dapui.util").notify = notify_handler
  end, debug.traceback)
end

return M
