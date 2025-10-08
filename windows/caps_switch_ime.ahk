#Requires AutoHotkey v2.0
SendMode("Input")
SetWorkingDir(A_ScriptDir)

SetCapsLockState("Off")  ; 启动时关闭 CapsLock

CapsLock:: {
    pressTime := A_TickCount
    KeyWait("CapsLock")
    duration := A_TickCount - pressTime

    if (duration >= 200) {
        state := GetKeyState("CapsLock", "T")
        SetCapsLockState(!state ? "On" : "Off")
    } else {
        Send("#{Space}")
    }
}