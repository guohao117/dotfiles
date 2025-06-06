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

    -- 检测操作系统
    local function detect_os()
        if wezterm.target_triple:find("windows") then
            return "Windows"
        elseif wezterm.target_triple:find("apple") or wezterm.target_triple:find("darwin") then
            return "macOS"
        else
            return "Linux"
        end
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
    config.window_background_opacity = 0.95
    config.hide_tab_bar_if_only_one_tab = true
    config.use_fancy_tab_bar = false

    -- 实时响应系统主题变化
    wezterm.on('window-config-reloaded', function(window, pane)
        local new_appearance = get_appearance()
        local overrides = window:get_config_overrides() or {}
        -- 只有当用户没有手动设置 color_scheme 时才自动切换
        if not overrides.color_scheme then
            if new_appearance:find("Dark") then
                overrides.color_scheme = "Tokyo Night"
            else
                overrides.color_scheme = "Tokyo Night Day"
            end
            window:set_config_overrides(overrides)
        end
    end)

    return config
end

return M
