local wezterm = require("wezterm")
local os_utils = require("utils.os")

local M = {}

function M.setup(opts)
  opts = opts or {}
  local config = {}

  local os_type = os_utils.detect_os()
  wezterm.log_info(string.format("[SSH Config] Detected OS: %s", os_type))

  if os_type == "Windows" then
    -- Windows 上禁用内置 ssh-agent，使用系统自带的
    config.mux_enable_ssh_agent = false
    wezterm.log_info("[SSH Config] Disabled mux_enable_ssh_agent for Windows")
  elseif os_type == "macOS" then
    -- macOS 使用内置的 ssh-agent 支持
    config.mux_enable_ssh_agent = true
    wezterm.log_info("[SSH Config] Enabled mux_enable_ssh_agent for macOS")
  elseif os_type == "Linux" then
    -- Linux 使用内置的 ssh-agent 支持
    config.mux_enable_ssh_agent = true
    wezterm.log_info("[SSH Config] Enabled mux_enable_ssh_agent for Linux")
  end

  return config
end

return M
