local os_utils = require("utils.os")

local configs = {
  Windows = {
    default_prog = { "pwsh.exe", "-NoLogo" },
    -- ...other Windows-specific settings...
  },
  macOS = {
    -- 不设置 default_prog，遵循系统默认 shell
    -- ...other macOS-specific settings...
  },
  Linux = {
    -- 不设置 default_prog，遵循系统默认 shell
    -- ...other Linux-specific settings...
  }
}

local function setup()
  local os = os_utils.detect_os()
  return configs[os]
end

return {
  setup = setup
}
