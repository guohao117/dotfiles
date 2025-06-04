-- Pull in the wezterm API
local wezterm = require("wezterm")
local conf_init = require("conf.init")

-- This is the configuration to be used by wezterm
local config = wezterm.config_builder()

-- 合并 conf/init.lua 的配置
for k, v in pairs(conf_init) do
	config[k] = v
end

return config
