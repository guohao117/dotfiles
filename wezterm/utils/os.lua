local wezterm = require("wezterm")

local function detect_os()
  if wezterm.target_triple:find("windows") then
    return "Windows"
  elseif wezterm.target_triple:find("apple") or wezterm.target_triple:find("darwin") then
    return "macOS"
  else
    return "Linux"
  end
end

return {
  detect_os = detect_os,
  -- 以后可以在这里添加更多与 OS 相关的函数
}
