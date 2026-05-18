local wezterm = require("wezterm")

-- Force log output for debugging
wezterm.log_info("[CONFIG] Configuration loading started...")

--[[
  WezTerm 配置模块加载器

  这个文件负责：
  1. 加载所有配置模块（appearance, ime, keymap, launch 等）
  2. 合并各模块返回的配置
  3. 自动收集并注册所有模块的 Command Palette 条目

  模块约定：
  - 每个模块必须有 setup(opts) 函数，返回配置 table

  示例模块：
  ```lua
  local M = {}

  function M.setup(opts)
    -- 初始化逻辑
    return {
      font_size = 14,
      -- 其他配置...
    }
  end

  return M
  ```

  配置选项：
  - enabled: boolean - 是否启用该模块
  - opts: table - 传递给模块 setup() 的选项
]]

-- 默认 plugin 配置
local default_plugins = {
  launch = { enabled = true, opts = {} },
  keymap = { enabled = true, opts = {} },
  appearance = { enabled = true, opts = {} },
  ime = { enabled = true, opts = {} },
  ssh = { enabled = true, opts = {} },
  -- 你可以在这里添加更多 plugin
  password = { enabled = true, opts = {}, enable_command_palette = true },
}

-- Extend package.path to include conf directory for plugin loading
package.path = package.path .. ";" .. wezterm.config_dir .. "/conf/?.lua"

local function merge_plugin_config(default, user)
  return {
    enabled = user.enabled ~= nil and user.enabled or default.enabled,
    opts = user.opts or default.opts or {},
    enable_command_palette = user.enable_command_palette ~= nil and user.enable_command_palette
      or (default.enable_command_palette ~= nil and default.enable_command_palette or true),
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

  -- 在初始化时就收集所有 command palette entries（缓存），而不是每次事件触发时重新计算
  local cached_command_palette_entries = {}

  for plugin, config_table in pairs(plugins) do
    if config_table.enabled then
      local ok, mod_or_err = pcall(require, "conf." .. plugin)
      if ok and type(mod_or_err) == "table" and type(mod_or_err.setup) == "function" then
        wezterm.log_info(string.format("[CONFIG] Loaded module: %s", "conf." .. plugin))
        local plugin_opts = config_table.opts
        local conf = mod_or_err.setup(plugin_opts)
        if type(conf) == "table" then
          merge_table(config, conf)
        end
      else
        local err_msg = ok and "Module does not return a table with setup function"
          or tostring(mod_or_err)
        wezterm.log_error(
          string.format("[CONFIG] Failed to load module: %s, error: %s", "conf." .. plugin, err_msg)
        )
      end
    end
  end

  return config
end

return {
  init = init,
}
