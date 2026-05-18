local wezterm = require("wezterm")
local os_utils = require("utils.os")

local M = {}

-- Define color-scheme names in one place so they can be changed easily.
-- Keeping them as local constants ensures all logic that compares by name
-- stays correct even if you rename the schemes later.
local SCHEME_DARK = "PencilDark"
local SCHEME_LIGHT = "PencilLight"

-- 获取系统外观
local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return "Light"
end

-- Internal helpers and state
local _handlers_registered = false
local _toggle_active_windows = {}
local _suppressed_reload_counts = {}

local function is_dark_appearance(appearance)
  if not appearance then
    return false
  end
  return appearance:lower():find("dark") ~= nil
end

local function opposite_scheme(scheme)
  if scheme == SCHEME_DARK then
    return SCHEME_LIGHT
  end
  return SCHEME_DARK
end

local function running_scheme()
  return (is_dark_appearance(get_appearance()) and SCHEME_DARK) or SCHEME_LIGHT
end

local function suppress_next_reload(window_id)
  _suppressed_reload_counts[window_id] = (_suppressed_reload_counts[window_id] or 0) + 1
end

local function consume_suppressed_reload(window_id)
  local count = _suppressed_reload_counts[window_id] or 0
  if count <= 0 then
    return false
  end

  count = count - 1
  if count == 0 then
    _suppressed_reload_counts[window_id] = nil
  else
    _suppressed_reload_counts[window_id] = count
  end
  return true
end

local function clear_color_scheme_override(window)
  local window_id = window:window_id()
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme == nil or overrides.color_scheme == "" then
    return
  end

  overrides.color_scheme = nil
  suppress_next_reload(window_id)
  if next(overrides) == nil then
    window:set_config_overrides({})
  else
    window:set_config_overrides(overrides)
  end
end

function M.setup(opts)
  opts = opts or {}

  -- Allow callers to override the default scheme names via opts.
  -- Support either `opts.scheme_dark`/`opts.scheme_light` or `opts.schemes = { dark=..., light=... }`.
  do
    local provided_dark = (opts.schemes and opts.schemes.dark) or opts.scheme_dark
    local provided_light = (opts.schemes and opts.schemes.light) or opts.scheme_light
    if provided_dark then
      SCHEME_DARK = provided_dark
    end
    if provided_light then
      SCHEME_LIGHT = provided_light
    end
  end

  local config = {}

  -- 根据系统主题自动切换配色
  config.color_scheme = running_scheme()

  -- 其他外观设置
  local base_font_size = 12.0
  if os_utils.detect_os() == "macOS" then
    config.font_size = base_font_size + 2
  else
    config.font_size = base_font_size
  end
  config.hide_tab_bar_if_only_one_tab = true
  config.use_fancy_tab_bar = false

  -- Event handlers (register once)
  if not _handlers_registered then
    wezterm.on("window-config-reloaded", function(window, pane)
      if not window then
        return
      end

      local window_id = window:window_id()
      if consume_suppressed_reload(window_id) then
        return
      end

      if not _toggle_active_windows[window_id] then
        return
      end

      _toggle_active_windows[window_id] = nil
      clear_color_scheme_override(window)
    end)

    wezterm.on("toggle-light-dark", function(window, pane)
      if not window then
        return
      end
      local window_id = window:window_id()
      local base_scheme = running_scheme()
      local overrides = window:get_config_overrides() or {}

      if _toggle_active_windows[window_id] then
        _toggle_active_windows[window_id] = nil
        clear_color_scheme_override(window)
        wezterm.log_info("Toggle: cleared override")
        return
      end

      overrides.color_scheme = opposite_scheme(base_scheme)
      _toggle_active_windows[window_id] = true
      suppress_next_reload(window_id)
      window:set_config_overrides(overrides)
      wezterm.log_info("Toggle: set override to " .. overrides.color_scheme)
    end)

    _handlers_registered = true
  end

  return config
end

-- 返回用于 command palette 的条目列表
function M.get_command_palette_entries()
  return {
    {
      brief = "Toggle Light/Dark Theme",
      icon = "md_theme_light_dark",
      action = wezterm.action.EmitEvent("toggle-light-dark"),
    },
  }
end

return M
