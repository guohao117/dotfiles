-- Pull in the wezterm API
local conf_init = require("conf.init")

-- 通过 init 函数生成 config，可传参控制 feature 开关
local config = conf_init.init()
config.term = "wezterm"

return config
