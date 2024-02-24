local M = {}

function M.load_defaults()
  local definitions = {
    {
      "TextYankPost",
      {
        group = "_general_settings",
        pattern = "*",
        desc = "Highlight text on yank",
        callback = function()
          vim.highlight.on_yank { higroup = "Search", timeout = 100 }
        end,
      },
    },
    {
      "FileType",
      {
        group = "_hide_dap_repl",
        pattern = "dap-repl",
        command = "set nobuflisted",
      },
    },
    {
      "FileType",
      {
        group = "_filetype_settings",
        pattern = { "lua" },
        desc = "fix gf functionality inside .lua files",
        callback = function()
          ---@diagnostic disable: assign-type-mismatch
          -- credit: https://github.com/sam4llis/nvim-lua-gf
          vim.opt_local.include = [[\v<((do|load)file|require|reload)[^''"]*[''"]\zs[^''"]+]]
          vim.opt_local.includeexpr = "substitute(v:fname,'\\.','/','g')"
          vim.opt_local.suffixesadd:prepend ".lua"
          vim.opt_local.suffixesadd:prepend "init.lua"

          for _, path in pairs(vim.api.nvim_list_runtime_paths()) do
            vim.opt_local.path:append(path .. "/lua")
          end
        end,
      },
    },
    {
      "FileType",
      {
        group = "_buffer_mappings",
        pattern = {
          "qf",
          "help",
          "man",
          "floaterm",
          "lspinfo",
          "lir",
          "lsp-installer",
          "null-ls-info",
          "tsplayground",
          "DressingSelect",
          "Jaq",
        },
        callback = function()
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
          vim.opt_local.buflisted = false
        end,
      },
    },
    {
      "VimResized",
      {
        group = "_auto_resize",
        pattern = "*",
        command = "tabdo wincmd =",
      },
    },
    {
      "FileType",
      {
        group = "_filetype_settings",
        pattern = "alpha",
        callback = function()
          vim.cmd [[
            set nobuflisted
          ]]
        end,
      },
    },
    {
      "FileType",
      {
        group = "_filetype_settings",
        pattern = "lir",
        callback = function()
          vim.opt_local.number = false
          vim.opt_local.relativenumber = false
        end,
      },
    },
    {
      "ColorScheme",
      {
        group = "_lvim_colorscheme",
        callback = function()
          require("plugins.breadcrumbs").get_winbar()
          local statusline_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" })
          local cursorline_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
          local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
          vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
          vim.api.nvim_set_hl(0, "CmpItemKindTabnine", { fg = "#CA42F0" })
          vim.api.nvim_set_hl(0, "CmpItemKindCrate", { fg = "#F64D00" })
          vim.api.nvim_set_hl(0, "CmpItemKindEmoji", { fg = "#FDE030" })
          vim.api.nvim_set_hl(0, "SLCopilot", { fg = "#6CC644", bg = statusline_hl.background })
          vim.api.nvim_set_hl(0, "SLGitIcon", { fg = "#E8AB53", bg = cursorline_hl.background })
          vim.api.nvim_set_hl(0, "SLBranchName", { fg = normal_hl.foreground, bg = cursorline_hl.background })
          vim.api.nvim_set_hl(0, "SLSeparator", { fg = cursorline_hl.background, bg = statusline_hl.background })
        end,
      },
    },
    { -- taken from AstroNvim
      "BufEnter",
      {
        group = "_dir_opened",
        nested = true,
        callback = function(args)
          local bufname = vim.api.nvim_buf_get_name(args.buf)
          if require("utils").is_directory(bufname) then
            vim.api.nvim_del_augroup_by_name "_dir_opened"
            vim.cmd "do User DirOpened"
            vim.api.nvim_exec_autocmds(args.event, { buffer = args.buf, data = args.data })
          end
        end,
      },
    },
    { -- taken from AstroNvim
      { "BufRead", "BufWinEnter", "BufNewFile" },
      {
        group = "_file_opened",
        nested = true,
        callback = function(args)
          local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
          if not (vim.fn.expand "%" == "" or buftype == "nofile") then
            vim.api.nvim_del_augroup_by_name "_file_opened"
            vim.api.nvim_exec_autocmds("User", { pattern = "FileOpened" })
            require("lsp").setup()
          end
        end,
      },
    },
    {
      "LspAttach",
      {
        group = "UserLspConfig",
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(args.buf, true)
          end
        end
      }
    }
  }

  M.define_autocmds(definitions)
end

--- Clean autocommand in a group if it exists
--- This is safer than trying to delete the augroup itself
---@param name string the augroup name
function M.clear_augroup(name)
  -- defer the function in case the autocommand is still in-use
  vim.schedule(function()
    pcall(function()
      vim.api.nvim_clear_autocmds { group = name }
    end)
  end)
end

function M.define_autocmds(definitions)
  for _, entry in ipairs(definitions) do
    local event = entry[1]
    local opts = entry[2]
    if type(opts.group) == "string" and opts.group ~= "" then
      local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = opts.group })
      if not exists then
        vim.api.nvim_create_augroup(opts.group, {})
      end
    end
    vim.api.nvim_create_autocmd(event, opts)
  end
end

return M
