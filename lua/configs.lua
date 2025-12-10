local M = {}
function M.init()
  local options = {
    relativenumber = true,
    wrap = true,
    breakindent = true,
    backup = false,                          -- creates a backup file
    clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
    messagesopt = "hit-enter,history:1000",
    cmdheight = 1,                           -- more space in the neovim command line for displaying messages
    completeopt = { "menuone", "noselect" },
    conceallevel = 0,                        -- so that `` is visible in markdown files
    fileencoding = "utf-8",                  -- the encoding written to a file
    foldmethod = "expr",                     -- folding, set to "expr" for treesitter based folding
    foldexpr = "nvim_treesitter#foldexpr()", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
    foldlevelstart = 99,
    hidden = true,                           -- required to keep multiple buffers and open multiple buffers
    hlsearch = true,                         -- highlight all matches on previous search pattern
    ignorecase = true,                       -- ignore case in search patterns
    mouse = "a",                             -- allow the mouse to be used in neovim
    pumheight = 10,                          -- pop up menu height
    showmode = false,                        -- we don't need to see things like -- INSERT -- anymore
    smartcase = true,                        -- smart case
    splitbelow = true,                       -- force all horizontal splits to go below current window
    splitright = true,                       -- force all vertical splits to go to the right of current window
    swapfile = false,                        -- creates a swapfile
    termguicolors = true,                    -- set term gui colors (most terminals support this)
    timeoutlen = 500,                        -- time to wait for a mapped sequence to complete (in milliseconds)
    title = true,                            -- set the title of window to the value of the titlestring
    titlestring = 'nvim %{expand("%:t")}',   -- what the title of the window will be set to
    undofile = true,                         -- enable persistent undo
    updatetime = 100,                        -- faster completion
    writebackup = false,                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
    expandtab = true,                        -- convert tabs to spaces
    shiftwidth = 2,                          -- the number of spaces inserted for each indentation
    tabstop = 2,                             -- insert 2 spaces for a tab
    cursorline = true,                       -- highlight the current line
    number = true,                           -- set numbered lines
    numberwidth = 4,                         -- set number column width to 2 {default 4}
    signcolumn = "yes",                      -- always show the sign column, otherwise it would shift the text each time
    scrolloff = 5,                           -- minimal number of screen lines to keep above and below the cursor.
    sidescrolloff = 4,                       -- minimal number of screen lines to keep left and right of the cursor.
    showcmd = false,
    ruler = false,
    laststatus = 3,
    jumpoptions = "clean,stack"
  }

  for k, v in pairs(options) do
    vim.opt[k] = v
  end

  vim.opt.formatoptions:remove { "r", "o" }

  --- @type vim.diagnostic.Opts
  local diagnostic_config = {
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = Icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = Icons.diagnostics.Warning,
        [vim.diagnostic.severity.HINT] = Icons.diagnostics.Hint,
        [vim.diagnostic.severity.INFO] = Icons.diagnostics.Information,
      },
      active = true,
    },
    virtual_lines = false,
    virtual_text = false,
    update_in_insert = false,
    underline = true,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
      source = true,
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(diagnostic_config)
end

return M
