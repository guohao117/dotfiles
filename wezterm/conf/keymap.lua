local wezterm = require("wezterm")

local M = {}

function M.setup()
  return {
    keys = {
      {
        key = "d",
        mods = "CTRL|ALT",
        action = wezterm.action_callback(function(window, pane)
          local overrides = window:get_config_overrides() or {}
          overrides.color_scheme = "Tokyo Night"
          window:set_config_overrides(overrides)
        end),
      },
      {
        key = "l",
        mods = "CTRL|ALT",
        action = wezterm.action_callback(function(window, pane)
          local overrides = window:get_config_overrides() or {}
          overrides.color_scheme = "Tokyo Night Day"
          window:set_config_overrides(overrides)
        end),
      },
    },
  }
end

return M
