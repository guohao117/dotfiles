local wezterm = require("wezterm")

-- Force log output for debugging
wezterm.log_info("[CONFIG] Configuration loading started...")

-- 默认 plugin 配置
local default_plugins = {
  launch = { enabled = true, opts = {} },
  keymap = { enabled = true, opts = {} },
  appearance = { enabled = true, opts = {} },
  ime = { enabled = true, opts = {} },
  -- 你可以在这里添加更多 plugin
}

local plugin_modules = {
  launch = "conf.launch",
  keymap = "conf.keymap",
  appearance = "conf.appearance",
  ime = "conf.ime",
  -- You can add more modules here
}

local function merge_plugin_config(default, user)
  return {
    enabled = user.enabled ~= nil and user.enabled or default.enabled,
    opts = user.opts or default.opts or {}
  }
end

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
-- @param opts table 可选参数，如 {appearance={enabled=true, opts={auto_switch_enabled=false}}}
-- @return table wezterm config 对象
local function init(opts)
  opts = opts or {}
  local plugins = {}
  for k, v in pairs(default_plugins) do
    local user_config = opts[k] or {}
    plugins[k] = merge_plugin_config(v, user_config)
  end

  local config = wezterm.config_builder()

  -- Initialize keys array
  config.keys = config.keys or {}

  for plugin, config_table in pairs(plugins) do
    if config_table.enabled then
      local modname = plugin_modules[plugin]
      if modname then
        local ok, mod_or_err = pcall(require, modname)
        if ok and type(mod_or_err) == "table" and type(mod_or_err.setup) == "function" then
          wezterm.log_info(string.format("[CONFIG] Loaded module: %s", modname))
          local plugin_opts = config_table.opts
          local conf = mod_or_err.setup(plugin_opts)
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
  end

  return config
end

return {
  init = init,
}
