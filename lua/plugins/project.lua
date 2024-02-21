local M = {}

function M.setup()
  local status_ok, project = pcall(require, "project_nvim")
  if not status_ok then
    return
  end

  project.setup({
    active = true,
    manual_mode = false,
    detection_methods = { "pattern" },
    patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "pom.xml" },
    ignore_lsp = {},
    exclude_dirs = {},
    show_hidden = false,
    silent_chdir = true,
    scope_chdir = "global",
  })
end

function M.get_plugin_config()
  return {
    {
      "ahmedkhalf/project.nvim",
      config = M.setup,
      event = "VimEnter",
      cmd = "Telescope projects",
    }
  }
end

return M
