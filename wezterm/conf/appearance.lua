local wezterm = require('wezterm')

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

    -- 根据系统主题自动切换配色
    local appearance = get_appearance()
    if appearance:find("Dark") then
        config.color_scheme = "Tokyo Night"
    else
        config.color_scheme = "Tokyo Night Day"
    end

    -- 其他外观设置
    config.font_size = 12.0
    config.window_background_opacity = 0.95
    config.hide_tab_bar_if_only_one_tab = true

    -- 实时响应系统主题变化
    wezterm.on('window-config-reloaded', function(window, pane)
        local new_appearance = get_appearance()
        local overrides = window:get_config_overrides() or {}
        if new_appearance:find("Dark") then
            overrides.color_scheme = "Tokyo Night"
        else
            overrides.color_scheme = "Tokyo Night Day"
        end
        window:set_config_overrides(overrides)
    end)

    return config
end

return M
