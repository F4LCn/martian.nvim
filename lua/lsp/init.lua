local M = {}
local autocmds = require "autocmds"

M.servers = {
  clangd = {},
  rust_analyzer = {},
  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}

local function add_lsp_buffer_options(bufnr)
  for k, v in pairs(Lsp.buffer_options) do
    vim.api.nvim_set_option_value(k, v, { buf = bufnr })
  end
end

local function add_lsp_buffer_keybindings(bufnr)
  local mappings = {
    normal_mode = "n",
    insert_mode = "i",
    visual_mode = "v",
  }

  for mode_name, mode_char in pairs(mappings) do
    for key, remap in pairs(Lsp.buffer_mappings[mode_name]) do
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
  if Lsp.document_highlight then
    autocmds.clear_augroup "lsp_document_highlight"
  end
  if Lsp.code_lens_refresh then
    autocmds.clear_augroup "lsp_code_lens_refresh"
  end
end

function M.common_on_init(client, bufnr)
  if Lsp.on_init_callback then
    Lsp.on_init_callback(client, bufnr)
    return
  end
end

function M.common_on_attach(client, bufnr)
  if Lsp.on_attach_callback then
    Lsp.on_attach_callback(client, bufnr)
  end
  local lu = require "lsp.utils"
  if Lsp.document_highlight then
    lu.setup_document_highlight(client, bufnr)
  end
  if Lsp.code_lens_refresh then
    lu.setup_codelens_refresh(client, bufnr)
  end
  add_lsp_buffer_keybindings(bufnr)
  add_lsp_buffer_options(bufnr)
  lu.setup_document_symbols(client, bufnr)
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
  mason_lspconfig.setup()

  local neodev_ok, neodev = pcall(require, "neodev")
  if not neodev_ok then
    vim.notify "no neodev"
    return
  end
  neodev.setup()


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

  --   local status_ok, null_ls = pcall(require, "null-ls")
  -- if not status_ok then
  --   vim.notify "no null-ls"
  -- end

  -- null_ls.setup(opts)


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

return M
