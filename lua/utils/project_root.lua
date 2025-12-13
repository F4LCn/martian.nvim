local M = {}

local function git_root(path)
  local fd = io.popen('git -C "' .. path .. '" rev-parse --show-toplevel 2> /dev/null')
  if not fd then
    return nil
  end
  local out = fd:read("*l")
  fd:close()
  return out
end

function M.find_root()
  local buf = vim.api.nvim_buf_get_name(0)
  if buf == "" then
    return nil
  end
  local dir = vim.fn.fnamemodify(buf, ":p:h")
  while dir and dir ~= "." and dir ~= "/" do
    local g = git_root(dir)
    if g and g ~= "" then
      return g
    end
    local parent = vim.fn.fnamemodify(dir, ":h")
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

function M.setup_autochdir()
  vim.api.nvim_create_augroup("_project_root", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
    group = "_project_root",
    callback = function()
      local root = M.find_root()
      if root and root ~= vim.fn.getcwd() then
        vim.schedule(function()
          vim.cmd("lcd " .. vim.fn.fnameescape(root))
        end)
      end
    end,
  })
end

return M
