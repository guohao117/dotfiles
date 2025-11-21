local wezterm = require("wezterm")

-- 加载插件 - 临时使用本地路径测试
local ime_plugin = wezterm.plugin.require("file:///Users/guohao/Workspaces/wezterm-ime-helper")

local M = {}

-- 符合 init.lua 的接口规范
function M.setup(opts)
  opts = opts or {}

  -- 调用插件的 setup
  if ime_plugin and ime_plugin.setup then
    ime_plugin.setup(opts)
  end

  return {}
end

-- 暴露插件的其他 API 供其他模块使用
M.switch_to_en = ime_plugin.switch_to_en
M.switch_to_ime = ime_plugin.switch_to_ime

-- 粘合层：提供 command palette 条目
-- 这里整合了 wezterm-ime-helper 的功能到 WezTerm 的 Command Palette
function M.get_command_palette_entries()
  return {
    {
      brief = "Switch to English IME",
      icon = "md_keyboard",
      action = ime_plugin.switch_to_en(),
    },
    {
      brief = "Switch to IME",
      icon = "md_translate",
      action = ime_plugin.switch_to_ime(),
    },
    {
      brief = "Toggle IME",
      icon = "md_swap_horiz",
      action = ime_plugin.toggle(),
    },
  }
end

return M
