local M = {}
M.methods = {}

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
end
M.methods.has_words_before = has_words_before

---@deprecated use M.methods.has_words_before instead
M.methods.check_backspace = function()
  return not has_words_before()
end

local T = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function feedkeys(key, mode)
  vim.api.nvim_feedkeys(T(key), mode, true)
end

M.methods.feedkeys = feedkeys

local function jumpable(dir)
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then
    return false
  end

  local win_get_cursor = vim.api.nvim_win_get_cursor
  local get_current_buf = vim.api.nvim_get_current_buf

  ---sets the current buffer's luasnip to the one nearest the cursor
  ---@return boolean true if a node is found, false otherwise
  local function seek_luasnip_cursor_node()
    -- TODO(kylo252): upstream this
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snippet = node.parent.snippet
    local exit_node = snippet.insert_nodes[0]

    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1

    -- exit early if we're past the exit node
    if exit_node then
      local exit_pos_end = exit_node.mark:pos_end()
      if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    node = snippet.inner_first:jump_into(1, true)
    while node ~= nil and node.next ~= nil and node ~= snippet do
      local n_next = node.next
      local next_pos = n_next and n_next.mark:pos_begin()
      local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1])
          or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

      -- Past unmarked exit node, exit early
      if n_next == nil or n_next == snippet.next then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end

      if candidate then
        luasnip.session.current_nodes[get_current_buf()] = node
        return true
      end

      local ok
      ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
      if not ok then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    -- No candidate, but have an exit node
    if exit_node then
      -- to jump to the exit node, seek to snippet
      luasnip.session.current_nodes[get_current_buf()] = snippet
      return true
    end

    -- No exit node, exit from snippet
    snippet:remove_from_jumplist()
    luasnip.session.current_nodes[get_current_buf()] = nil
    return false
  end

  if dir == -1 then
    return luasnip.in_snippet() and luasnip.jumpable(-1)
  else
    return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
  end
end

M.methods.jumpable = jumpable

function M.setup()
  local cmp = require "cmp"
  local luasnip = require "luasnip"
  local cmp_window = require "cmp.config.window"
  local cmp_mapping = require "cmp.config.mapping"

  local status_cmp_ok, cmp_types = pcall(require, "cmp.types.cmp")
  if not status_cmp_ok then
    print("could not require cmp types")
    return
  end

  luasnip.config.set_config {
    history = false,
    updateevents = "TextChanged, TextChangedI",
  }

  local ConfirmBehavior = cmp_types.ConfirmBehavior
  local SelectBehavior = cmp_types.SelectBehavior

  local source_names = {
    nvim_lsp = "(LSP)",
    emoji = "(Emoji)",
    path = "(Path)",
    calc = "(Calc)",
    vsnip = "(Snip)",
    luasnip = "(Snip)",
    buffer = "(Buf)",
    tmux = "(TMUX)",
    treesitter = "(TS)",
    lazydev = "(VIM)",
  }

  local duplicates = {
    buffer = nil,
    path = nil,
    nvim_lsp = 1,
    luasnip = 1,
  }

  ---@diagnostic disable-next-line: redundant-parameter
  cmp.setup {
    enabled = function()
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
      if buftype == "prompt" then
        return false
      end
      return true
    end,
    confirm_opts = {
      behavior = ConfirmBehavior.Replace,
      select = false,
    },
    completion = {
      ---@usage The minimum length of a word to complete on.
      keyword_length = 1,
    },
    experimental = {
      ghost_text = false,
      native_menu = false,
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      max_width = 0,
      kind_icons = Icons.kind,
      source_names = source_names,
      duplicates = duplicates,
      duplicates_default = 0,
      format = function(entry, vim_item)
        local max_width = 0
        if max_width ~= 0 and #vim_item.abbr > max_width then
          vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. Icons.ui.Ellipsis
        end
        vim_item.kind = Icons.kind[vim_item.kind]

        if entry.source.name == "crates" then
          vim_item.kind = Icons.misc.Package
          vim_item.kind_hl_group = "CmpItemKindCrate"
        end

        if entry.source.name == "lab.quick_data" then
          vim_item.kind = Icons.misc.CircuitBoard
          vim_item.kind_hl_group = "CmpItemKindConstant"
        end

        if entry.source.name == "emoji" then
          vim_item.kind = Icons.misc.Smiley
          vim_item.kind_hl_group = "CmpItemKindEmoji"
        end
        vim_item.menu = source_names[entry.source.name]
        vim_item.dup = duplicates[entry.source.name] or nil
        return vim_item
      end,
    },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp_window.bordered(),
      documentation = cmp_window.bordered(),
    },
    sources = {
      {
        name = "nvim_lsp",
        entry_filter = function(entry, ctx)
          local kind = require("cmp.types.lsp").CompletionItemKind[entry:get_kind()]
          if kind == "Snippet" and ctx.prev_context.filetype == "java" then
            return false
          end
          return true
        end,
      },
      { name = "treesitter" },
      { name = "lazydev" },
      { name = "buffer" },
      { name = "crates" },
      { name = "nvim_lua" },
      { name = "luasnip" },
      { name = "path" },
      { name = "calc" },
      { name = "emoji" },
      { name = "tmux" },
      { name = "crates" },
    },
    mapping = cmp_mapping.preset.insert {
      ["<C-k>"] = cmp_mapping(cmp_mapping.select_prev_item(), { "i", "c" }),
      ["<C-j>"] = cmp_mapping(cmp_mapping.select_next_item(), { "i", "c" }),
      ["<Down>"] = cmp_mapping(cmp_mapping.select_next_item { behavior = SelectBehavior.Select }, { "i" }),
      ["<Up>"] = cmp_mapping(cmp_mapping.select_prev_item { behavior = SelectBehavior.Select }, { "i" }),
      ["<C-d>"] = cmp_mapping.scroll_docs(4),
      ["<C-u>"] = cmp_mapping.scroll_docs(-4),
      ["<C-y>"] = cmp_mapping {
        i = cmp_mapping.confirm { behavior = ConfirmBehavior.Replace, select = false },
        c = function(fallback)
          if cmp.visible() then
            cmp.confirm { behavior = ConfirmBehavior.Replace, select = false }
          else
            fallback()
          end
        end,
      },
      ["<Tab>"] = cmp_mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        elseif jumpable(1) then
          luasnip.jump(1)
        elseif has_words_before() then
          -- cmp.complete()
          fallback()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp_mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-Space>"] = cmp_mapping.complete(),
      ["<C-e>"] = cmp_mapping.abort(),
      ["<CR>"] = cmp_mapping(function(fallback)
        if cmp.visible() then
          local confirm_opts = {
            behavior = ConfirmBehavior.Replace,
            select = false,
          }
          local is_insert_mode = function()
            return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
          end
          if is_insert_mode() then -- prevent overwriting brackets
            confirm_opts.behavior = ConfirmBehavior.Replace
          end
          local entry = cmp.get_selected_entry()
          if cmp.confirm(confirm_opts) then
            return -- success, exit early
          end
        end
        fallback() -- if not exited early, always fallback
      end),
    },
  }

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "path" },
      { name = "cmdline" },
    },
  })
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })
end

function M.get_plugin_config()
  return {
    {
      "hrsh7th/nvim-cmp",
      config = M.setup,
      event = { "InsertEnter", "CmdlineEnter" },
      dependencies = {
        "nvim-lspconfig",
        "cmp-nvim-lsp",
        "cmp_luasnip",
        "cmp-buffer",
        "cmp-path",
        "cmp-cmdline",
        "rafamadriz/friendly-snippets",
        "L3MON4D3/LuaSnip"
      },
    },
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
    { "Bilal2453/luvit-meta",     lazy = true },
    { "hrsh7th/cmp-nvim-lsp",     lazy = true },
    { "saadparwaiz1/cmp_luasnip", lazy = true },
    { "hrsh7th/cmp-buffer",       lazy = true },
    { "hrsh7th/cmp-path",         lazy = true },
    {
      "hrsh7th/cmp-cmdline",
      lazy = true,
    },
    {
      "L3MON4D3/LuaSnip",
      build = (function()
        if vim.fn.has 'win32' == 1 then
          return
        end
        return 'make install_jsregexp'
      end)(),
      event = "InsertEnter",
      dependencies = {
        "friendly-snippets",
      },
    },
    { "rafamadriz/friendly-snippets" },
  }
end

return M
