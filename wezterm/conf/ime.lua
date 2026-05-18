local wezterm = require("wezterm")

-- 加载插件 - 临时使用本地路径测试
local ime_plugin = wezterm.plugin.require("https://github.com/guohao117/wezterm-ime-helper")

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

return M
