local wezterm = require("wezterm")

-- Force log output for debugging
wezterm.log_info("[CONFIG] Configuration loading started...")

-- 默认 plugin 开关
local default_plugins = {
  launch = true,
  keymap = true,
  appearance = true,
  ime = true,
  -- 你可以在这里添加更多 plugin
}

local plugin_modules = {
  launch = "conf.launch",
  keymap = "conf.keymap",
  appearance = "conf.appearance",
  ime = "conf.ime",
  -- You can add more modules here
}

local function merge_table(dst, src)
  for k, v in pairs(src) do
    if k == "keys" and type(dst[k]) == "table" and type(v) == "table" then
      -- Merge key bindings instead of overwriting
      for _, key in ipairs(v) do
        table.insert(dst[k], key)
      end
    else
      dst[k] = v
    end
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

  -- Initialize keys array
  config.keys = config.keys or {}

  for plugin, modname in pairs(plugin_modules) do
    if plugins[plugin] then
      local ok, mod_or_err = pcall(require, modname)
      if ok and type(mod_or_err) == "table" and type(mod_or_err.setup) == "function" then
        wezterm.log_info(string.format("[CONFIG] Loaded module: %s", modname))
        local conf = mod_or_err.setup(opts)
        if type(conf) == "table" then
          merge_table(config, conf)
        end
      else
        local err_msg = ok and "Module does not return a table with setup function"
          or tostring(mod_or_err)
        wezterm.log_error(
          string.format("[CONFIG] Failed to load module: %s, error: %s", modname, err_msg)
        )
      end
    end
  end

  return config
end

return {
  init = init,
}
