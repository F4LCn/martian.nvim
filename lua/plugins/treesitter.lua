local M = {}

function M.setup()
  if #vim.api.nvim_list_uis() == 0 then
    return
  end

  local ensure_installed = { "lua", "c", "cpp", "rust", "typescript", "javascript", "python", "zig", "json", "toml",
    "markdown", "bash", "regex", "comment", }

  local _, nvim_treesitter = pcall(require, 'nvim-treesitter')
  nvim_treesitter.install(ensure_installed)
end

function M.get_plugin_config()
  return {
    {
      "nvim-treesitter/nvim-treesitter",
      branch = "main",
      config = M.setup,
      build = ":TSUpdate",
      cmd = {
        "TSInstall",
        "TSUninstall",
        "TSUpdate",
        "TSUpdateSync",
        "TSInstallInfo",
        "TSInstallSync",
        "TSInstallFromGrammar",
      },
      event = "User FileOpened",
    },
    {
      "romgrk/nvim-treesitter-context",
      config = function()
        require("treesitter-context").setup {
          enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
          throttle = true, -- Throttles plugin updates (may improve performance)
          max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        }
      end
    },
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      event = 'VeryLazy',

      branch = 'main',

      -- ["ia"] = "@parameter.inner",
      -- ["aa"] = "@parameter.outer",
      -- ["af"] = "@function.outer",
      -- ["if"] = "@function.inner",
      -- ["ac"] = "@class.outer",
      -- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
      -- ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      -- ["ib"] = "@block.inner",
      -- ["ob"] = "@block.outer",

      keys = {
        {
          '[f',
          function() require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects') end,
          desc = 'prev function',
          mode = { 'n', 'x', 'o' }
        },
        {
          ']f',
          function() require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects') end,
          desc = 'next function',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[F',
          function() require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects') end,
          desc = 'prev function end',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']F',
          function() require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects') end,
          desc = 'next function end',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[a',
          function() require('nvim-treesitter-textobjects.move').goto_previous_start('@parameter.outer', 'textobjects') end,
          desc = 'prev argument',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']a',
          function() require('nvim-treesitter-textobjects.move').goto_next_start('@parameter.outer', 'textobjects') end,
          desc = 'next argument',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[A',
          function() require('nvim-treesitter-textobjects.move').goto_previous_end('@parameter.outer', 'textobjects') end,
          desc = 'prev argument end',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']A',
          function() require('nvim-treesitter-textobjects.move').goto_next_end('@parameter.outer', 'textobjects') end,
          desc = 'next argument end',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[s',
          function() require('nvim-treesitter-textobjects.move').goto_previous_start('@block.outer', 'textobjects') end,
          desc = 'prev block',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']s',
          function() require('nvim-treesitter-textobjects.move').goto_next_start('@block.outer', 'textobjects') end,
          desc = 'next block',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[S',
          function() require('nvim-treesitter-textobjects.move').goto_previous_end('@block.outer', 'textobjects') end,
          desc = 'prev block',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']S',
          function() require('nvim-treesitter-textobjects.move').goto_next_end('@block.outer', 'textobjects') end,
          desc = 'next block',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[c',
          function() require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects') end,
          desc = 'prev block',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']c',
          function() require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects') end,
          desc = 'next block',
          mode = { 'n', 'x', 'o' },
        },
        {
          '[C',
          function() require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects') end,
          desc = 'prev block',
          mode = { 'n', 'x', 'o' },
        },
        {
          ']C',
          function() require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects') end,
          desc = 'next block',
          mode = { 'n', 'x', 'o' },
        },
        {
          'ia',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@parameter.inner', 'textobjects') end,
          desc = 'inner parameter',
          mode = { 'x', 'o' },
        },
        {
          'aa',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@parameter.outer', 'textobjects') end,
          desc = 'outer parameter',
          mode = { 'x', 'o' },
        },
        {
          'af',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects') end,
          desc = 'outer function',
          mode = { 'x', 'o' },
        },
        {
          'if',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects') end,
          desc = 'inner function',
          mode = { 'x', 'o' },
        },
        {
          'ac',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects') end,
          desc = 'outer class',
          mode = { 'x', 'o' },
        },
        {
          'ic',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects') end,
          desc = 'inner class',
          mode = { 'x', 'o' },
        },
        {
          'as',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@scope.inner', 'textobjects') end,
          desc = 'around scope',
          mode = { 'x', 'o' },
        },
        {
          'ib',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@block.inner', 'textobjects') end,
          desc = 'inner block',
          mode = { 'x', 'o' },
        },
        {
          'ob',
          function() require('nvim-treesitter-textobjects.select').select_textobject('@block.outer', 'textobjects') end,
          desc = 'outer block',
          mode = { 'x', 'o' },
        },

      },

      opts = {
        move = {
          enable = true,
          set_jumps = true,
        },
        swap = {
          enable = true,
        },
      },
    },
  }
end

return M
