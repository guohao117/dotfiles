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

local function effective_scheme_for_window(window)
  local overrides = window:get_config_overrides() or {}
  if overrides.color_scheme and overrides.color_scheme ~= "" then
    return overrides.color_scheme, overrides
  end
  local appearance = get_appearance()
  return (is_dark_appearance(appearance) and SCHEME_DARK) or SCHEME_LIGHT, overrides
end

function M.setup(opts)
  opts = opts or {}
  local auto_switch_enabled = opts.auto_switch_enabled
  if auto_switch_enabled == nil then
    auto_switch_enabled = true
  end

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
  local appearance = get_appearance()
  if appearance:find("Dark") then
    config.color_scheme = SCHEME_DARK
  else
    config.color_scheme = SCHEME_LIGHT
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

  -- Event handlers (register once)
  if not _handlers_registered then
    -- Toggle handler: cycle auto -> dark -> light -> auto
    wezterm.on("toggle-light-dark", function(window, pane)
      if not window then
        return
      end
      local scheme, overrides = effective_scheme_for_window(window)
      overrides = overrides or {}

      if not overrides.color_scheme or overrides.color_scheme == "" then
        -- currently auto: set explicit opposite
        overrides.color_scheme = opposite_scheme(scheme)
        window:set_config_overrides(overrides)
        wezterm.log_info("Toggle: set to " .. overrides.color_scheme .. ", disabled auto switching")
        return
      end

      -- there is an explicit override; cycle through states
      if overrides.color_scheme == SCHEME_DARK then
        overrides.color_scheme = SCHEME_LIGHT
        window:set_config_overrides(overrides)
        wezterm.log_info("Toggle: switched override to " .. SCHEME_LIGHT)
      elseif overrides.color_scheme == SCHEME_LIGHT then
        -- clear only the color_scheme key to go back to auto
        overrides.color_scheme = nil
        if next(overrides) == nil then
          window:set_config_overrides({})
        else
          window:set_config_overrides(overrides)
        end
        wezterm.log_info("Toggle: cleared override, re-enabled auto switching")
      else
        -- unknown override value: set to dark as a fallback
        overrides.color_scheme = SCHEME_DARK
        window:set_config_overrides(overrides)
        wezterm.log_info("Toggle: set to fallback " .. SCHEME_DARK)
      end
    end)

    -- Auto-apply handler: respect manual overrides; otherwise apply expected scheme
    wezterm.on("update-right-status", function(window, pane)
      if not auto_switch_enabled then
        return
      end
      if not window then
        return
      end
      local new_appearance = get_appearance()
      local expected_scheme = is_dark_appearance(new_appearance) and SCHEME_DARK or SCHEME_LIGHT
      local current_scheme, overrides = effective_scheme_for_window(window)

      -- If overrides.color_scheme exists, assume manual control, skip auto
      if overrides and overrides.color_scheme and overrides.color_scheme ~= "" then
        return
      end

      if current_scheme ~= expected_scheme then
        overrides = overrides or {}
        overrides.color_scheme = expected_scheme
        window:set_config_overrides(overrides)
        wezterm.log_info("Auto-applied color scheme: " .. expected_scheme)
      end
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
