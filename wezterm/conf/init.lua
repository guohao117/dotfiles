local wezterm = require("wezterm")

-- 默认 plugin 开关
local default_plugins = {
  launch = true,
  keymap = true,
  appearance = true,
  -- 你可以在这里添加更多 plugin
}

local plugin_modules = {
  launch = "conf.launch",
  keymap = "conf.keymap",
  appearance = "conf.appearance",
  -- 你可以在这里添加更多模块
}

local function merge_table(dst, src)
  for k, v in pairs(src) do
    dst[k] = v
  end
end

--- 初始化 wezterm 配置
-- @param opts table 可选参数，控制 plugin 开关，如 {plugins={appearance=false}}
-- @return table wezterm config 对象
local function init(opts)
  opts = opts or {}
  local plugins = {}
  if opts.plugins then
    for k, v in pairs(default_plugins) do
      if opts.plugins[k] ~= nil then
        plugins[k] = opts.plugins[k]
      else
        plugins[k] = v
      end
    end
  else
    for k, v in pairs(default_plugins) do
      plugins[k] = v
    end
  end

  local config = wezterm.config_builder()

  for plugin, modname in pairs(plugin_modules) do
    if plugins[plugin] then
      local ok, mod = pcall(require, modname)
      if ok and type(mod) == "table" and type(mod.setup) == "function" then
        local conf = mod.setup(opts)
        if type(conf) == "table" then
          merge_table(config, conf)
        end
      end
    end
  end

  return config
end

return {
  init = init
}
