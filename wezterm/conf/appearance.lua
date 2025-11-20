local wezterm = require("wezterm")
local os_utils = require("utils.os")

local M = {}

-- 获取系统外观
local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return "Light"
end

-- Toggle light/dark scheme for the window
function M.toggle_light_dark(window, pane)
  if not window then return end
  local overrides = window:get_config_overrides() or {}

  if overrides.color_scheme then
    -- Clear overrides to re-enable auto switching
    window:set_config_overrides({})
    wezterm.log_info("Toggle: cleared overrides, re-enabled auto switching")
  else
    -- Set to opposite of current effective scheme
    local current = overrides.color_scheme or (get_appearance():find("Dark") and "Tokyo Night" or "Tokyo Night Day")
    local target = (current == "Tokyo Night") and "Tokyo Night Day" or "Tokyo Night"
    overrides.color_scheme = target
    window:set_config_overrides(overrides)
    wezterm.log_info("Toggle: set to " .. target .. ", disabled auto switching")
  end
end

function M.setup(opts)
  opts = opts or {}
  local auto_switch_enabled = opts.auto_switch_enabled
  if auto_switch_enabled == nil then
    auto_switch_enabled = true
  end

  local config = {}

  -- 根据系统主题自动切换配色
  local appearance = get_appearance()
  if appearance:find("Dark") then
    config.color_scheme = "Tokyo Night"
  else
    config.color_scheme = "Tokyo Night Day"
  end

  -- 其他外观设置
  local base_font_size = 12.0
  if os_utils.detect_os() == "macOS" then
    config.font_size = base_font_size + 2
  else
    config.font_size = base_font_size
  end
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false

  -- 实时响应系统主题变化
  wezterm.on("update-right-status", function(window, pane)
    if not auto_switch_enabled then return end
    local new_appearance = get_appearance()
    local overrides = window:get_config_overrides() or {}

    -- If overrides.color_scheme exists, assume manual control, skip auto
    if overrides.color_scheme then return end

    local expected_scheme = new_appearance:find("Dark") and "Tokyo Night" or "Tokyo Night Day"
    local current_scheme = config.color_scheme

    if current_scheme ~= expected_scheme then
      overrides.color_scheme = expected_scheme
      window:set_config_overrides(overrides)
      wezterm.log_info("Auto-applied color scheme: " .. expected_scheme)
    end
  end)

  return config
end

return M
