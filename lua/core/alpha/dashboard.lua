local M = {}

M.banner = {
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                           =#%%*-                                                         ",
  "                          %@@@@@@#                                                        ",
  "                          @@@@@@@@@:                                                      ",
  "                          @@@@@@@@@@-                                                     ",
  "                          @@@@@@@@@@@*                                                    ",
  "                          @@@@@@@@@@@@%.                                                  ",
  "                          @@@@@@@@@@@@@@-                                                 ",
  "                          @@@@@@@@@@@@@@@+                                                ",
  "                          @@@@@@@@@@@@@@@@%.              .::::::::.                      ",
  "                          @@@@@@@@:@@@@@@@@@:           =@@@@@@@@@#                       ",
  "                          @@@@@@@@ .%@@@@@@@@+         :@@@@@@@@@%                        ",
  "                          %@@@@@@@   +@@@@@@@@*        :@@@@@@@@%                         ",
  "                          %@@@@@@@    -@@@@@@@@%.      :@@@@@@@@.                         ",
  "                          %@@@@@@@     .%@@@@@@@@=     .@@@@@@@#                          ",
  "                          #@@@@@@@       *@@@@@@@@*    .@@@@@@@#                          ",
  "                          #@@@@@@@.       =@@@@@@@@#.  .@@@@@@@#                          ",
  "                          #@@@@@@@.        :@@@@@@@@@- .@@@@@@@#                          ",
  "                          #@@@@@@@.    .=#%..#@@@@@@@*..@@@@@@@#                          ",
  "                          #@@@@@@@.  =%@@@@@: =@@@*-   .@@@@@@@#                          ",
  "                          #@@@@@@@. :@@@@@@@@+          @@@@@@@%                          ",
  "                          *@@@@@@@.  +@@@@@@@@#         @@@@@@@%                          ",
  "                          *@@@@@@@:   :@@@@@@@@%:       @@@@@@@%                          ",
  "                          *@@@@@@@:    .%@@@@@@@@=      @@@@@@@%                          ",
  "                          %@@@@@@@:      +@@@@@@@@*     @@@@@@@@                          ",
  "                         -@@@@@@@@-       -@@@@@@@@%.   @@@@@@@@                          ",
  "                        -@@@@@@@@@-        .%@@@@@@@@=  @@@@@@@@                          ",
  "                       :@@@@@@@@@@.          *@@@@@@@@* @@@@@@@@                          ",
  "                       ########*=             =@@@@@@@@#@@@@@@@@                          ",
  "                                               :@@@@@@@@@@@@@@@@                          ",
  "                                                .#@@@@@@@@@@@@@@                          ",
  "                                                  +@@@@@@@@@@@@@                          ",
  "                                                   -@@@@@@@@@@@@                          ",
  "                                                    .%@@@@@@@@@@.                         ",
  "                                                      *@@@@@@@@@.                         ",
  "                                                       =@@@@@@@@.                         ",
  "                                                        .#@@@@@-                          ",
  "                                                          .:-:                            ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
  "                                                                                          ",
}

M.banner_small = {
  "                                                 ",
  "                                                 ",
  "                                                 ",
  "███████╗░░██╗██╗██╗░░░░░░█████╗░░█████╗░███╗░░██╗",
  "██╔════╝░██╔╝██║██║░░░░░██╔══██╗██╔══██╗████╗░██║",
  "█████╗░░██╔╝░██║██║░░░░░██║░░╚═╝██║░░██║██╔██╗██║",
  "██╔══╝░░███████║██║░░░░░██║░░██╗██║░░██║██║╚████║",
  "██║░░░░░╚════██║███████╗╚█████╔╝╚█████╔╝██║░╚███║",
  "╚═╝░░░░░░░░░░╚═╝╚══════╝░╚════╝░░╚════╝░╚═╝░░╚══╝ ",
  "                                                 ",
  "                                                 ",
  "                                                 ",
}

function M.get_sections()
  local header = {
    type = "text",
    val = function()
      local alpha_wins = vim.tbl_filter(function(win)
        local buf = vim.api.nvim_win_get_buf(win)
        return vim.api.nvim_get_option_value("filetype", { buf = buf }) == "alpha"
      end, vim.api.nvim_list_wins())

      if vim.api.nvim_win_get_height(alpha_wins[#alpha_wins]) < 60 then
        return M.banner_small
      end
      return M.banner
    end,
    opts = {
      position = "center",
      hl = "Comment",
      spacing = 2,
    },
  }

  local buttons = {
    opts = {
      hl_shortcut = "Include",
      spacing = 1,
    },
    entries = {
    },
  }
  return {
    header = header,
    -- buttons = buttons,
  }
end

return M
