local M = {}
local Log = require("core.log")
local autocmds = require "autocmds"

M.servers = {
  "clangd",
  "lua_ls",
  "ts_ls",
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
      ["K"] = { "<cmd>lua vim.lsp.buf.hover({border = 'single'})<cr>", "Show hover" },
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
  capabilities.textDocument.semanticTokens.multilineTokenSupport = true
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
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true)
  end
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
  local default_behaviors = M.get_common_opts()
  vim.lsp.config('*', {
    capabilities = default_behaviors.capabilities,
    root_markers = { '.git' },
    on_attach = default_behaviors.on_attach,
    on_exit = default_behaviors.on_exit,
    on_init = default_behaviors.on_init,
  })

  vim.lsp.enable({ "ts_ls", "lua_ls", "clangd", "zls" })

  require('crates').setup({
    lsp = {
      enabled = true,
      on_attach = function(client, bufnr)
        vim.keymap.set("n", "<leader>rf", function()
          if vim.fn.expand("%:t") == "Cargo.toml" then
            require("crates").show_features_popup()
          end
        end, { desc = "Show Crate features", buffer = bufnr })
        default_behaviors.on_attach(client, bufnr)
      end,
      actions = true,
      completion = true,
      hover = true,
    },
  })

  -- Enable rounded borders in :LspInfo window.
  require("lspconfig.ui.windows").default_options.border = "rounded"
end

function M.get_plugin_config()
  return {
    -- {
    --   "neovim/nvim-lspconfig",
    --   lazy = true,
    --   dependencies = {
    --     "mason-lspconfig.nvim",
    --     { 'j-hui/fidget.nvim', opts = {} },
    --     "jose-elias-alvarez/typescript.nvim",
    --   },
    -- },
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
                vim.lsp.buf.hover({ border = "single" })
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
