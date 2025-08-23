---@brief
--- https://github.com/zigtools/zls
---
--- Zig LSP implementation + Zig Language Server

return {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zir' },
  root_markers = { 'zls.json', 'build.zig', '.git' },
  workspace_required = false,
  zig_lib_path = "~/.local/share/zigup/master/files/lib",
  settings = {
    enable_argument_placeholders = false,
    inlay_hints_hide_redundant_param_names = true,
    inlay_hints_hide_redundant_param_names_last_token = true,
    inlay_hints_show_struct_literal_field_type = false,
    semantic_tokens = "full",
    warn_style = true,
  }
}
