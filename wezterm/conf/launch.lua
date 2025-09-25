local os_utils = require("utils.os")
local wezterm = require("wezterm")

local configs = {
  Windows = {
    default_prog = { "pwsh.exe", "-NoLogo" },
    launch_menu = {
      {
        label = "PowerShell",
        args = { "pwsh.exe", "-NoLogo" },
      },
      {
        label = "Command Prompt",
        args = { "cmd.exe" },
      },
      {
        label = "MSYS2 MINGW64",
        args = { "C:\\msys64\\msys2_shell.cmd", "-defterm", "-here", "-no-start", "-mingw64" },
      },
      {
        label = "MSYS2 UCRT64",
        args = { "C:\\msys64\\msys2_shell.cmd", "-defterm", "-here", "-no-start", "-ucrt64" },
      },
      {
        label = "MSYS2 MSYS",
        args = { "C:\\msys64\\msys2_shell.cmd", "-defterm", "-here", "-no-start", "-msys" },
      },
    },
    -- ...other Windows-specific settings...
  },
  macOS = {
    -- 不设置 default_prog，遵循系统默认 shell
    -- ...other macOS-specific settings...
  },
  Linux = {
    -- 不设置 default_prog，遵循系统默认 shell
    -- ...other Linux-specific settings...
  },
}

local function setup()
  local os = os_utils.detect_os()
  return configs[os]
end

return {
  setup = setup,
}
