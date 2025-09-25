#!/bin/bash

# Simple OSC sequence sender for WezTerm IME control
# Sends OSC sequence 9527 to test IME reception

send_osc() {
  local state="$1"
  local encoded=$(echo -n "$state" | base64)
  echo "Sending OSC 1337 SetUserVar: wezterm_ime_control=$state (base64: $encoded)"
  printf "\033]1337;SetUserVar=wezterm_ime_control=%s\007" "$encoded"
}

case "${1:-help}" in
  "en"|"EN")
    send_osc "EN"
    ;;
  "ime"|"IME")
    send_osc "IME"
    ;;
  "test")
    echo "Testing both sequences..."
    send_osc "EN"
    sleep 1
    send_osc "IME"
    ;;
  *)
    echo "Usage: $0 [en|ime|test]"
    echo "  en   - Send EN sequence via OSC 1337 SetUserVar"
    echo "  ime  - Send IME sequence via OSC 1337 SetUserVar"
    echo "  test - Send both sequences via OSC 1337 SetUserVar"
    ;;
esac
