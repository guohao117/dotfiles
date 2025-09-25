local wezterm = require("wezterm")
local os_utils = require("utils.os")

local M = {}

function M.setup()
  local config = {}

  -- 获取系统外观
  local function get_appearance()
    if wezterm.gui then
      return wezterm.gui.get_appearance()
    end
    return "Light"
  end

  -- 检测操作系统
  local function detect_os()
    return os_utils.detect_os()
  end

  -- 根据系统主题自动切换配色
  local appearance = get_appearance()
  if appearance:find("Dark") then
    config.color_scheme = "Tokyo Night"
  else
    config.color_scheme = "Tokyo Night Day"
  end

  -- 其他外观设置
  local base_font_size = 12.0
  if detect_os() == "macOS" then
    config.font_size = base_font_size + 2
  else
    config.font_size = base_font_size
  end
  -- config.window_background_opacity = 0.95
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false

  -- 实时响应系统主题变化
  wezterm.on("update-right-status", function(window, pane)
    local new_appearance = get_appearance()
    local overrides = window:get_config_overrides() or {}

    -- 获取当前配置的主题
    local current_scheme = overrides.color_scheme or config.color_scheme
    local expected_scheme

    if new_appearance:find("Dark") then
      expected_scheme = "Tokyo Night"
    else
      expected_scheme = "Tokyo Night Day"
    end

    -- 只有当主题不匹配时才更新
    if current_scheme ~= expected_scheme then
      overrides.color_scheme = expected_scheme
      window:set_config_overrides(overrides)
    end
  end)

  return config
end

return M
