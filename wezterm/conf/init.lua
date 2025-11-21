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
  - 如果模块想添加 Command Palette 条目，实现 get_command_palette_entries() 函数
  - get_command_palette_entries() 应该返回一个 array，每个元素包含：
    * brief: string (必需) - 命令的简短描述
    * icon: string (可选) - Nerd Fonts 图标名称
    * action: wezterm.action (必需) - 要执行的动作
    * doc: string (可选) - 详细说明

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

  function M.get_command_palette_entries()
    return {
      {
        brief = "My Custom Command",
        icon = "md_rocket",
        action = wezterm.action.EmitEvent("my-event"),
      }
    }
  end

  return M
  ```

  配置选项：
  - enabled: boolean - 是否启用该模块
  - opts: table - 传递给模块 setup() 的选项
  - enable_command_palette: boolean - 是否加载该模块的 Command Palette 条目
]]

-- 默认 plugin 配置
local default_plugins = {
  launch = { enabled = true, opts = {}, enable_command_palette = true },
  keymap = { enabled = true, opts = {}, enable_command_palette = true },
  appearance = { enabled = true, opts = {}, enable_command_palette = true },
  ime = { enabled = true, opts = {}, enable_command_palette = true },
  -- 你可以在这里添加更多 plugin
}

-- Extend package.path to include conf directory for plugin loading
package.path = package.path .. ";" .. wezterm.config_dir .. "/conf/?.lua"

local function merge_plugin_config(default, user)
  return {
    enabled = user.enabled ~= nil and user.enabled or default.enabled,
    opts = user.opts or default.opts or {},
    enable_command_palette = user.enable_command_palette ~= nil and user.enable_command_palette
        or (default.enable_command_palette ~= nil and default.enable_command_palette or true)
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

  -- 存储所有已加载的模块，用于后续收集 command palette entries
  local loaded_modules = {}

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
        -- 保存已加载的模块引用
        loaded_modules[plugin] = mod_or_err
      else
        local err_msg = ok and "Module does not return a table with setup function"
            or tostring(mod_or_err)
        wezterm.log_error(
          string.format("[CONFIG] Failed to load module: %s, error: %s", "conf." .. plugin, err_msg)
        )
      end
    end
  end

  -- 统一注册 command palette，使用反射机制收集所有模块的条目
  wezterm.on("augment-command-palette", function(window, pane)
    local entries = {}

    -- 遍历所有已加载的模块
    for plugin_name, module in pairs(loaded_modules) do
      -- 检查该模块是否启用了 command palette
      local plugin_config = plugins[plugin_name]
      if plugin_config and plugin_config.enable_command_palette then
        -- 检查模块是否有 get_command_palette_entries 方法
        if type(module.get_command_palette_entries) == "function" then
          -- 使用 pcall 防止某个模块出错影响其他模块
          local ok, module_entries = pcall(module.get_command_palette_entries)
          if ok and type(module_entries) == "table" then
            wezterm.log_info(string.format("[Command Palette] Loading entries from conf.%s", plugin_name))
            for _, entry in ipairs(module_entries) do
              table.insert(entries, entry)
            end
          elseif not ok then
            wezterm.log_error(
              string.format(
                "[Command Palette] Failed to get entries from conf.%s: %s",
                plugin_name,
                tostring(module_entries)
              )
            )
          end
        end
      end
    end

    return entries
  end)

  return config
end

return {
  init = init,
}
