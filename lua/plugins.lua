-- TODO: split plugins with big configs into their own files
return {
  "F4LCn/oxocharcoal.nvim",
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'tpope/vim-sleuth',
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = true,
    dependencies = {
      "mason-lspconfig.nvim",
      { 'j-hui/fidget.nvim', opts = {} },
      "folke/neodev.nvim"
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
    "williamboman/mason.nvim",
    config = function()
      require("core.mason").setup()
    end,
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
    build = function()
      pcall(function()
        require("mason-registry").refresh()
      end)
    end,
    event = "User FileOpened",
    lazy = true,
  },
  { "Tastyep/structlog.nvim", lazy = true },
  { "nvim-lua/plenary.nvim",  cmd = { "PlenaryBustedFile", "PlenaryBustedDirectory" }, lazy = true },
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    config = function()
      require("core.telescope").setup()
    end,
    dependencies = { "telescope-fzy-native.nvim" },
    lazy = true,
    cmd = "Telescope",
    enabled = Builtin.telescope.active,
  },
  { "nvim-telescope/telescope-fzy-native.nvim", build = "make", lazy = true, enabled = Builtin.telescope.active },
  -- Install nvim-cmp, and buffer source as a dependency
  {
    "hrsh7th/nvim-cmp",
    config = function()
      print("cmp setup")
      require("core.cmp").setup()
    end,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "cmp-nvim-lsp",
      "cmp_luasnip",
      "cmp-buffer",
      "cmp-path",
      "cmp-cmdline",
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip"
    },
  },
  { "hrsh7th/cmp-nvim-lsp",                     lazy = true },
  { "saadparwaiz1/cmp_luasnip",                 lazy = true },
  { "hrsh7th/cmp-buffer",                       lazy = true },
  { "hrsh7th/cmp-path",                         lazy = true },
  {
    "hrsh7th/cmp-cmdline",
    lazy = true,
    enabled = Builtin.cmp and Builtin.cmp.cmdline.enable or false,
  },
  {
    "L3MON4D3/LuaSnip",
    build = (function()
      -- Build Step is needed for regex support in snippets
      -- This step is not supported in many windows environments
      -- Remove the below condition to re-enable on windows
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
  { "rafamadriz/friendly-snippets", lazy = true },
  {
    "folke/neodev.nvim",
    lazy = true,
  },
  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("core.autopairs").setup()
    end,
    enabled = Builtin.autopairs.active,
    dependencies = { "nvim-treesitter/nvim-treesitter", "hrsh7th/nvim-cmp" },
  },
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("core.treesitter").setup()
    end,
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
    -- Lazy loaded by Comment.nvim pre_hook
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
  },
  -- NvimTree
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("core.nvimtree").setup()
    end,
    enabled = Builtin.nvimtree.active,
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle" },
    event = "User DirOpened",
  },
  -- Lir
  {
    "tamago324/lir.nvim",
    config = function()
      require("core.lir").setup()
    end,
    enabled = Builtin.lir.active,
    event = "User DirOpened",
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("core.gitsigns").setup()
    end,
    event = "User FileOpened",
    cmd = "Gitsigns",
    enabled = Builtin.gitsigns.active,
  },
  -- Whichkey
  {
    "folke/which-key.nvim",
    config = function()
      require("core.which-key").setup()
    end,
    cmd = "WhichKey",
    event = "VeryLazy",
    enabled = Builtin.which_key.active,
  },
  -- Comments
  {
    "numToStr/Comment.nvim",
    config = function()
      require("core.comment").setup()
    end,
    keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
    event = "User FileOpened",
    enabled = Builtin.comment.active,
  },
  -- project.nvim
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("core.project").setup()
    end,
    enabled = Builtin.project.active,
    event = "VimEnter",
    cmd = "Telescope projects",
  },
  -- Icons
  {
    "nvim-tree/nvim-web-devicons",
    enabled = true,
    lazy = true,
  },
  -- Status Line and Bufferline
  {
    -- "hoob3rt/lualine.nvim",
    "nvim-lualine/lualine.nvim",
    -- "Lunarvim/lualine.nvim",
    config = function()
      require("core.lualine").setup()
    end,
    event = "VimEnter",
    enabled = Builtin.lualine.active,
  },
  -- breadcrumbs
  {
    "SmiteshP/nvim-navic",
    config = function()
      require("core.breadcrumbs").setup()
    end,
    event = "User FileOpened",
    enabled = Builtin.breadcrumbs.active,
  },
  {
    "akinsho/bufferline.nvim",
    config = function()
      require("core.bufferline").setup()
    end,
    branch = "main",
    event = "User FileOpened",
    enabled = Builtin.bufferline.active,
  },
  -- Debugging
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("core.dap").setup()
    end,
    lazy = true,
    dependencies = {
      "rcarriga/nvim-dap-ui",
    },
    enabled = Builtin.dap.active,
  },
  -- Debugger user interface
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("core.dap").setup_ui()
    end,
    lazy = true,
    enabled = Builtin.dap.active,
  },

  -- alpha
  {
    "goolord/alpha-nvim",
    config = function()
      require("core.alpha").setup()
    end,
    enabled = Builtin.alpha.active,
    event = "VimEnter",
  },
  -- Terminal
  {
    "akinsho/toggleterm.nvim",
    branch = "main",
    init = function()
      require("core.terminal").init()
    end,
    config = function()
      require("core.terminal").setup()
    end,
    cmd = {
      "ToggleTerm",
      "TermExec",
      "ToggleTermToggleAll",
      "ToggleTermSendCurrentLine",
      "ToggleTermSendVisualLines",
      "ToggleTermSendVisualSelection",
    },
    keys = Builtin.terminal.open_mapping,
    enabled = Builtin.terminal.active,
  },
  -- SchemaStore
  {
    "b0o/schemastore.nvim",
    lazy = true,
  },
  {
    "RRethy/vim-illuminate",
    config = function()
      require("core.illuminate").setup()
    end,
    event = "User FileOpened",
    enabled = Builtin.illuminate.active,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("core.indentlines").setup()
    end,
    event = "User FileOpened",
    enabled = Builtin.indentlines.active,
  },
  {
    "lunarvim/bigfile.nvim",
    config = function()
      pcall(function()
        require("bigfile").config({})
      end)
    end,
    enabled = true,
    event = { "FileReadPre", "BufReadPre", "User FileOpened" },
  },
  {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
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
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
  },
  "tpope/vim-surround",
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup()
    end
  },
  "mg979/vim-visual-multi",
  {
    "casonadams/simple-diagnostics.nvim",
    config = function()
      require("simple-diagnostics").setup({
        virtual_text = false,
        message_area = true,
        signs = true,
      })
    end,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts) require 'lsp_signature'.setup(opts) end
  },
}
