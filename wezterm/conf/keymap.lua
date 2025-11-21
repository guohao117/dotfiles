local wezterm = require("wezterm")

local M = {}

function M.setup(opts)
  return {
    keys = {
      {
        key = "t",
        mods = "CTRL|ALT",
        action = wezterm.action.EmitEvent("toggle-light-dark"),
      },
      {
        key = "P",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(window, pane)
          -- Switch to English IME before opening command palette
          local ime = require("conf.ime")
          if ime and ime.switch_to_en then
            local switch_action = ime.switch_to_en()
            if switch_action then
              window:perform_action(switch_action, pane)
            end
          end
          -- Then open command palette
          window:perform_action(wezterm.action.ActivateCommandPalette, pane)
        end),
      },
    },
  }
end

return M
