#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%

SetCapsLockState, Off  ; 兼容性更好

lastCapsTime := 0

hideTrayTip() {
    TrayTip  ; Attempt to hide it the normal way.
    if SubStr(A_OSVersion,1,3) = "10." {
        Menu Tray, NoIcon
        Sleep 200  ; It may be necessary to adjust this sleep.
        Menu Tray, Icon
    }
}

switchCapsLockState() {
    state := GetKeyState("CapsLock", "T")
    nextState := !state
    SetCapsLockState % nextState
    
    return nextState
}

showTip(isOn, duration := 1000) {
    title := isOn ? "CapsLock: ON" : "CapsLock: OFF"
    text := isOn ? "已打开" : "已关闭"
    TrayTip, %title%, %text%, 1, 16
    SetTimer, HideTrayTip, -%duration%
}

HideTrayTip:
    hideTrayTip()
return

toggleAndShowTip() {
    nextState := switchCapsLockState()
    showTip(nextState)
}

CapsLock::
    now := A_TickCount
    if (now - lastCapsTime < 300) {
        ; 防抖：300ms 内多次触发只响应一次
        return
    }
    lastCapsTime := now

    KeyWait, CapsLock, T0.2

    if (ErrorLevel) {
        ; 长按 - 切换 Caps Lock
        toggleAndShowTip()
    } else {
        ; 短按 - 等待可能的第二次按键
        KeyWait, CapsLock, D T0.3

        if (ErrorLevel) {
            ; 单击 - 切换输入法
            Send #{Space}
        } else {
            ; 双击 - 切换 Caps Lock
            toggleAndShowTip()
            KeyWait, CapsLock
        }
    }

    ; 确保按键完全释放
    KeyWait, CapsLock
return