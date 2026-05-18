local wezterm = require("wezterm")

local plugin = wezterm.plugin.require("file:///Users/guohao/Workspaces/wez-password")

local M = {}

local function first_existing_path(paths)
  for _, path in ipairs(paths) do
    local file = io.open(path, "r")
    if file then
      file:close()
      wezterm.log_info(string.format("[password.lua] Found rbw at: %s", path))
      return path
    end
  end

  wezterm.log_warn("[password.lua] rbw not found in any of the expected paths")
  return nil
end

local function merge_plugin_opts(opts)
  local merged = {}

  if type(opts) == "table" then
    for key, value in pairs(opts) do
      merged[key] = value
    end
  end

  if not merged.backend or merged.backend == "" then
    merged.backend = "rbw"
  end

  if not merged.rbw_bin or merged.rbw_bin == "" then
    merged.rbw_bin = first_existing_path({
      "/opt/homebrew/bin/rbw",
      "/usr/local/bin/rbw",
      "/usr/bin/rbw",
    }) or "rbw"
  end

  if not merged.bw_bin or merged.bw_bin == "" then
    merged.bw_bin = first_existing_path({
      "/opt/homebrew/bin/bw",
      "/usr/local/bin/bw",
      "/usr/bin/bw",
    }) or "bw"
  end

  if merged.backend == "bw" and (not merged.bw_session or merged.bw_session == "") then
    merged.bw_session = os.getenv("BW_SESSION")
  end

  wezterm.log_info(string.format("[password.lua] rbw_bin: %s", merged.rbw_bin))
  wezterm.log_info(string.format("[password.lua] backend: %s", merged.backend))
  wezterm.log_info(string.format("[password.lua] bw_bin: %s", merged.bw_bin))

  return merged
end

function M.setup(opts)
  opts = merge_plugin_opts(opts)
  local config = {}

  if plugin and plugin.apply_to_config then
    plugin.apply_to_config(config, opts)
  end

  return config
end

return M
