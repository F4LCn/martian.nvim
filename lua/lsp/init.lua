local M = {}
local Log = require("core.log")
local autocmds = require "autocmds"

M.servers = {
  clangd = {},
  -- rust_analyzer = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
  ts_ls = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayVariableTypeHints = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "literals",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayVariableTypeHints = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = false,
        includeInlayEnumMemberValueHints = true,
      },
    },
    inlay_hints = true,
  },
  zls = {
    enable_argument_placeholders = false,
    inlay_hints_hide_redundant_param_names = true,
    inlay_hints_hide_redundant_param_names_last_token = true,
    inlay_hints_show_struct_literal_field_type = false,
    semantic_tokens = "full",
    warn_style = true,
  }
}

local function add_lsp_buffer_options(bufnr)
  local buffer_options = {
    omnifunc = "v:lua.vim.lsp.omnifunc",
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  }
  for k, v in pairs(buffer_options) do
    vim.api.nvim_set_option_value(k, v, { buf = bufnr })
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  local mappings = {
    normal_mode = "n",
    insert_mode = "i",
    visual_mode = "v",
  }
  local buffer_mappings = {
    normal_mode = {
      ["K"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show hover" },
      ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Goto definition" },
      ["gD"] = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Goto Declaration" },
      ["gr"] = { "<cmd>lua vim.lsp.buf.references()<cr>", "Goto references" },
      ["gI"] = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Goto Implementation" },
      ["gs"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "show signature help" },
      ["gl"] = {
        function()
          local float = vim.diagnostic.config().float

          if float then
            local config = type(float) == "table" and float or {}
            config.scope = "line"

            vim.diagnostic.open_float(config)
          end
        end,
        "Show line diagnostics",
      },
    },
    insert_mode = {},
    visual_mode = {},
  }

  for mode_name, mode_char in pairs(mappings) do
    for key, remap in pairs(buffer_mappings[mode_name]) do
      local opts = { buffer = bufnr, desc = remap[2], noremap = true, silent = true }
      vim.keymap.set(mode_char, key, remap[1], opts)
    end
  end
end

function M.common_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if status_ok then
    return cmp_nvim_lsp.default_capabilities(capabilities)
  end

  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      "documentation",
      "detail",
      "additionalTextEdits",
    },
  }

  return capabilities
end

function M.common_on_exit(_, _)
  autocmds.clear_augroup "lsp_document_highlight"
  autocmds.clear_augroup "lsp_code_lens_refresh"
end

function M.common_on_init(client, bufnr)
end

function M.common_on_attach(client, bufnr)
  local lu = require "lsp.utils"
  lu.setup_document_highlight(client, bufnr)
  lu.setup_codelens_refresh(client, bufnr)
  add_lsp_buffer_keybindings(bufnr)
  add_lsp_buffer_options(bufnr)
  lu.setup_document_symbols(client, bufnr)
  -- if client.server_capabilities.inlayHintProvider then
  --   print("inlay_hints supported")
  --   vim.lsp.inlay_hint.enable(bufnr, true)
  -- end
end

function M.get_common_opts()
  return {
    on_attach = M.common_on_attach,
    on_init = M.common_on_init,
    on_exit = M.common_on_exit,
    capabilities = M.common_capabilities(),
  }
end

function M.setup()
  local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
  if not mason_lspconfig_ok then
    print "no mason-lspconfig"
    return
  end

  mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(M.servers),
  }

  local capabilities = M.get_common_opts()
  mason_lspconfig.setup_handlers {
    function(server_name)
      if server_name == "rust-analyser" then
        return
      end
      local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
      if not lsp_status_ok then
        return
      end
      if server_name == "clangd" then
        lspconfig[server_name].setup {
          cmd = {
            "clangd",
            "--function-arg-placeholders=0",
          },
          capabilities = capabilities.capabilities,
          on_attach = capabilities.on_attach,
          on_init = capabilities.on_init,
          on_exit = capabilities.on_exit,
          settings = M.servers[server_name],
          filetypes = (M.servers[server_name] or {}).filetypes
        }
      else
        lspconfig[server_name].setup {
          capabilities = capabilities.capabilities,
          on_attach = capabilities.on_attach,
          on_init = capabilities.on_init,
          on_exit = capabilities.on_exit,
          settings = M.servers[server_name],
          filetypes = (M.servers[server_name] or {}).filetypes
        }
      end
    end
  }

  require('crates').setup({
    lsp = {
      enabled = true,
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>rf", function()
          if vim.fn.expand("%:t") == "Cargo.toml" then
            require("crates").show_features_popup()
          end
        end, { desc = "Show Crate features", buffer = bufnr })
        capabilities.on_attach(client, bufnr)
      end,
      actions = true,
      completion = true,
      hover = true,
    },
  })

  -- local function set_handler_opts_if_not_set(name, handler, opts)
  --   if debug.getinfo(vim.lsp.handlers[name], "S").source:find(vim.env.VIMRUNTIME, 1, true) then
  --     vim.lsp.handlers[name] = vim.lsp.with(handler, opts)
  --   end
  -- end

  -- set_handler_opts_if_not_set("textDocument/hover", vim.lsp.handlers.hover, { border = "rounded" })
  -- set_handler_opts_if_not_set("textDocument/signatureHelp", vim.lsp.handlers.signature_help, { border = "rounded" })

  -- Enable rounded borders in :LspInfo window.
  require("lspconfig.ui.windows").default_options.border = "rounded"
end

function M.get_plugin_config()
  return {
    {
      "neovim/nvim-lspconfig",
      lazy = true,
      dependencies = {
        "mason-lspconfig.nvim",
        { 'j-hui/fidget.nvim', opts = {} },
        "jose-elias-alvarez/typescript.nvim",
      },
    },
    {
      "williamboman/mason-lspconfig.nvim",
      cmd = { "LspInstall", "LspUninstall" },
      lazy = true,
      event = "User FileOpened",
      dependencies = "mason.nvim",
    },
    -- {
    --   "jose-elias-alvarez/null-ls.nvim"
    -- },
    {
      "p00f/clangd_extensions.nvim",
      opts = {
        highlight = "LspInlayHint",
      }
    },
    {
      "pmizio/typescript-tools.nvim",
      dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
      ft = { 'typescript', 'javascript', 'svelte' }
    },
    {
      'mrcjkb/rustaceanvim',
      dependencies = {
        'saecki/crates.nvim',
      },
      ft = { 'rust' },
      opts = {
        server = {
          on_attach = function(_, bufnr)
            add_lsp_buffer_keybindings(bufnr)
            vim.keymap.set("n", "<leader>ds", function()
              vim.cmd.RustLsp("debuggables")
            end, { desc = "Rust Debuggables", buffer = bufnr })
            vim.keymap.set("n", "K", function()
              if vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
                require("crates").show_popup()
              else
                vim.lsp.buf.hover()
              end
            end, { desc = "Show Crate Documentation", buffer = bufnr })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = false,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- Add clippy lints for Rust.
              checkOnSave = {
                allFeatures = false,
                command = "clippy",
                extraArgs = { "--no-deps" },
              },
              procMacro = {
                enable = true,
                ignored = {
                  ["async-trait"] = { "async_trait" },
                  ["napi-derive"] = { "napi" },
                  ["async-recursion"] = { "async_recursion" },
                },
              },
            },
          },
        },
      },
      config = function(_, opts)
        vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
      end,
    },
    {
      "nvim-neotest/neotest",
      optional = true,
      opts = function(_, opts)
        opts.adapters = opts.adapters or {}
        vim.list_extend(opts.adapters, {
          require("rustaceanvim.neotest"),
        })
      end,
    },
    {
      'saecki/crates.nvim',
      event = { "BufRead Cargo.toml" },
    },
  }
end

return M
