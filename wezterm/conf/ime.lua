local wezterm = require('wezterm')
local os_utils = require("utils.os")

local M = {}

local IME_STATE = {
  EN = "EN",
  IME = "IME"
}

-- 跨平台输入法切换
local function switch_input_method(state)
  local os_name = os_utils.detect_os()
  if os_name == "macOS" then
    if state == "EN" then
      os.execute('macism "com.apple.keylayout.ABC"')
    elseif state == "IME" then
      os.execute('macism "com.apple.inputmethod.SCIM.ITABC"')
    end
  elseif os_name == "Windows" then
    -- TODO: Windows 切换输入法命令
  elseif os_name == "Linux" then
    -- TODO: Linux 切换输入法命令
  end
end

function M.setup(opts)
  opts = opts or {}

  wezterm.log_info("[IME] IME module setup called")

  wezterm.on('user-var-changed', function(window, pane, name, value)
    wezterm.log_info(string.format("[IME] user-var-changed: %s = %s", name, value))
    if name == 'wezterm_ime_control' or name == 'IME_CONTROL' then
      local state = (value or ""):upper()
      if state == IME_STATE.EN or state == IME_STATE.IME then
        switch_input_method(state)
        wezterm.log_info(string.format("[IME] Switched input method to %s", state))
      else
        wezterm.log_error(string.format("[IME] Invalid user variable value: %s", value))
      end
    end
  end)

  return {}
end

M.IME_STATE = IME_STATE

return M