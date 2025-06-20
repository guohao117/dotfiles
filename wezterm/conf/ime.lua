local wezterm = require('wezterm')

local M = {}

function M.setup(opts)
  opts = opts or {}
  
  -- 使用 GitHub 插件替代本地实现
  local ime_plugin = wezterm.plugin.require("https://github.com/guohao117/wezterm-ime-helper")
  ime_plugin.setup(opts)
  
  return {}
end

return M