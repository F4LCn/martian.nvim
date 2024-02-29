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
  tsserver = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "literals",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayVariableTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = "literals",
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayVariableTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
    inlay_hints = true,
  },
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
    vim.notify "no mason-lspconfig"
    return
  end

  mason_lspconfig.setup {
    ensure_installed = vim.tbl_keys(M.servers),
  }

  local capabilities = M.get_common_opts()
  mason_lspconfig.setup_handlers {
    function(server_name)
      local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
      if not lsp_status_ok then
        return
      end
      lspconfig[server_name].setup {
        capabilities = capabilities.capabilities,
        on_attach = capabilities.on_attach,
        on_init = capabilities.on_init,
        on_exit = capabilities.on_exit,
        settings = M.servers[server_name],
        filetypes = (M.servers[server_name] or {}).filetypes
      }
    end
  }

  local status_ok, null_ls = pcall(require, "null-ls")
  if not status_ok then
    vim.notify "no null-ls"
  end

  null_ls.setup(capabilities)


  for _, sign in ipairs(vim.tbl_get(vim.diagnostic.config(), "signs", "values") or {}) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = sign.name })
  end

  local function set_handler_opts_if_not_set(name, handler, opts)
    if debug.getinfo(vim.lsp.handlers[name], "S").source:find(vim.env.VIMRUNTIME, 1, true) then
      vim.lsp.handlers[name] = vim.lsp.with(handler, opts)
    end
  end

  set_handler_opts_if_not_set("textDocument/hover", vim.lsp.handlers.hover, { border = "rounded" })
  set_handler_opts_if_not_set("textDocument/signatureHelp", vim.lsp.handlers.signature_help, { border = "rounded" })

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
        'j-hui/fidget.nvim',
        "folke/neodev.nvim",
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
    {
      "jose-elias-alvarez/null-ls.nvim"
    },
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
      ft = { 'rust' },
    },
  }
end

return M
