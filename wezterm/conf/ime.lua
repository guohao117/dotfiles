local wezterm = require('wezterm')

local M = {}

-- IME state constants
local IME_STATE = {
  EN = "EN",
  IME = "IME"
}

-- Default OSC sequence number for IME control
local DEFAULT_OSC_NUMBER = 9527

-- Parse IME OSC sequence data
local function parse_ime_osc(data)
  -- Expected OSC sequence format: \033]9527;ime;<state>\007
  -- where <state> can be "EN" or "IME"
  local state = data:match("^ime[;:](.+)$")
  if state then
    return state:upper()
  end
  return nil
end

-- Handle IME control request event
local function handle_ime_control(window, pane, data)
  local state = parse_ime_osc(data)
  if state and (state == IME_STATE.EN or state == IME_STATE.IME) then
    wezterm.log_info(string.format("[IME] OSC sequence received: switching to %s", state))

    -- Optionally send acknowledgment back to remote
    if pane then
      local feedback = string.format("\033]%d;ime_ack;%s\007", DEFAULT_OSC_NUMBER, state)
      wezterm.log_info(string.format("[IME] Would send acknowledgment: %s", feedback))
    end

    -- Here you would call your binary instead of the old ime_commands
    wezterm.log_info(string.format("[IME] External binary should handle switching to %s", state))
  else
    wezterm.log_error(string.format("[IME] Invalid OSC data received: %s", tostring(data)))
  end
end

function M.setup(opts)
  opts = opts or {}

  -- Allow customization of OSC sequence number
  local osc_number = opts.ime_osc_number or DEFAULT_OSC_NUMBER

  wezterm.log_info(string.format("[IME] IME control module loaded, listening on OSC %d", osc_number))

  -- Use OSC 1337 SetUserVar approach (WezTerm documented method)
  wezterm.on('user-var-changed', function(window, pane, name, value)
    if name == 'wezterm_ime_control' or name == 'IME_CONTROL' then
      local state = value:upper()
      wezterm.log_info(string.format("[IME] User variable %s changed to: %s", name, state))

      if state == IME_STATE.EN or state == IME_STATE.IME then
        wezterm.log_info(string.format("[IME] External binary should handle switching to %s", state))
      else
        wezterm.log_error(string.format("[IME] Invalid user variable value: %s", value))
      end
    end
  end)

  -- No manual key bindings - user will use OS shortcuts
  return {}
end

-- Utility function to generate the escape sequence string for remote usage
function M.generate_ime_escape_sequence(state)
  state = state:upper()
  if state ~= IME_STATE.EN and state ~= IME_STATE.IME then
    return nil, "Invalid state: " .. tostring(state)
  end
  -- Use OSC 1337 SetUserVar format with base64 encoding
  local encoded_state = wezterm.base64_encode(state)
  return string.format("\033]1337;SetUserVar=wezterm_ime_control=%s\007", encoded_state), nil
end

-- Test function for debugging sequence reception
function M.test_ime_sequence_reception()
  wezterm.log_info("[IME] Testing sequence reception...")

  wezterm.log_info("[IME] Test 1: EN sequence")
  -- Simulate sequence reception (for testing logs)
  wezterm.log_info("[IME] OSC sequence received: switching to EN")

  wezterm.time.call_after(2, function()
    wezterm.log_info("[IME] Test 2: IME sequence")
    wezterm.log_info("[IME] OSC sequence received: switching to IME")
  end)

  wezterm.time.call_after(4, function()
    wezterm.log_info("[IME] Test 3: Invalid sequence")
    wezterm.log_error("[IME] Invalid OSC data received: invalid_state")
  end)

  wezterm.log_info("[IME] Sequence reception test completed - check logs above")
end

-- Export constants for external use
M.IME_STATE = IME_STATE
M.DEFAULT_OSC_NUMBER = DEFAULT_OSC_NUMBER

return M
