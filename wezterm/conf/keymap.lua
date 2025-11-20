local wezterm = require("wezterm")

local M = {}

function M.setup(opts)
  return {
    keys = {
      {
        key = "t",
        mods = "CTRL|ALT",
        action = wezterm.action_callback(function(window, pane)
          require("conf.appearance").toggle_light_dark(window, pane)
        end),
      },
    },
  }
end

return M
