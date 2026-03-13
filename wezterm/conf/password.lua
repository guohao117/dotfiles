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

  if not merged.rbw_bin or merged.rbw_bin == "" then
    merged.rbw_bin = first_existing_path({
      "/opt/homebrew/bin/rbw",
      "/usr/local/bin/rbw",
      "/usr/bin/rbw",
    }) or "rbw"
  end

  wezterm.log_info(string.format("[password.lua] rbw_bin: %s", merged.rbw_bin))

  return merged
end

function M.setup(opts)
  opts = merge_plugin_opts(opts)

  -- 调用插件的 setup
  if plugin and plugin.setup then
    return plugin.setup(opts)
  end

  return {}
end

function M.get_command_palette_entries(opts)
  opts = opts or {}

  local entries = {
    {
      brief = opts.command_palette_password_brief or "Insert password from rbw",
      doc = opts.command_palette_password_doc
        or "Search your rbw vault and paste the selected password into the active pane.",
      action = wezterm.action.EmitEvent("wez-password.rbw.open-password"),
    },
  }

  local enable_username = opts.enable_username_command_palette
  if enable_username == nil then
    enable_username = true
  end

  if enable_username then
    table.insert(entries, {
      brief = opts.command_palette_username_brief or "Insert username from rbw",
      doc = opts.command_palette_username_doc
        or "Search your rbw vault and paste the selected username into the active pane.",
      action = wezterm.action.EmitEvent("wez-password.rbw.open-username"),
    })
  end

  return entries
end

return M
