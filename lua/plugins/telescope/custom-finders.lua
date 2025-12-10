local M = {}

local _, builtin = pcall(require, "telescope.builtin")
local _, finders = pcall(require, "telescope.finders")
local _, pickers = pcall(require, "telescope.pickers")
local _, sorters = pcall(require, "telescope.sorters")
local _, themes = pcall(require, "telescope.themes")
local _, actions = pcall(require, "telescope.actions")
local _, previewers = pcall(require, "telescope.previewers")
local _, make_entry = pcall(require, "telescope.make_entry")

local copy_to_clipboard_action = function(prompt_bufnr)
  local _, action_state = pcall(require, "telescope.actions.state")
  local entry = action_state.get_selected_entry()
  local version = entry.value
  vim.fn.setreg("+", version)
  vim.fn.setreg('"', version)
  vim.notify("Copied " .. version .. " to clipboard", vim.log.levels.INFO)
  actions.close(prompt_bufnr)
end

function M.find_project_files(opts)
  opts = opts or {}
  local ok = pcall(builtin.git_files, opts)

  if not ok then
    builtin.find_files(opts)
  end
end

return M
