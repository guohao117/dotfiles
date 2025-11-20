#Requires AutoHotkey v2.0
SendMode("Input")
SetWorkingDir(A_ScriptDir)

SetCapsLockState("Off")  ; 启动时关闭 CapsLock

; 自动切换输入法变量
global lastInputTime := A_TickCount
global autoSwitchEnabled := false  ; 自动切换开关，默认关闭

; 设置定时器检查空闲时间（每30秒检查一次）
SetTimer(CheckIdleTime, 30000)

; 使用热键钩子监听所有按键（不拦截）- 只在启用自动切换时激活
#HotIf autoSwitchEnabled
*~a:: ResetInputTimer()
*~b:: ResetInputTimer()
*~c:: ResetInputTimer()
*~d:: ResetInputTimer()
*~e:: ResetInputTimer()
*~f:: ResetInputTimer()
*~g:: ResetInputTimer()
*~h:: ResetInputTimer()
*~i:: ResetInputTimer()
*~j:: ResetInputTimer()
*~k:: ResetInputTimer()
*~l:: ResetInputTimer()
*~m:: ResetInputTimer()
*~n:: ResetInputTimer()
*~o:: ResetInputTimer()
*~p:: ResetInputTimer()
*~q:: ResetInputTimer()
*~r:: ResetInputTimer()
*~s:: ResetInputTimer()
*~t:: ResetInputTimer()
*~u:: ResetInputTimer()
*~v:: ResetInputTimer()
*~w:: ResetInputTimer()
*~x:: ResetInputTimer()
*~y:: ResetInputTimer()
*~z:: ResetInputTimer()
*~0:: ResetInputTimer()
*~1:: ResetInputTimer()
*~2:: ResetInputTimer()
*~3:: ResetInputTimer()
*~4:: ResetInputTimer()
*~5:: ResetInputTimer()
*~6:: ResetInputTimer()
*~7:: ResetInputTimer()
*~8:: ResetInputTimer()
*~9:: ResetInputTimer()
*~Space:: ResetInputTimer()
*~Enter:: ResetInputTimer()
*~Backspace:: ResetInputTimer()
*~Tab:: ResetInputTimer()
*~LButton:: ResetInputTimer()
*~RButton:: ResetInputTimer()
#HotIf

; 重置输入计时器
ResetInputTimer() {
    global lastInputTime
    lastInputTime := A_TickCount
}

; 检查当前是否为英文输入法
IsEnglishIME() {
    ; 获取当前窗口句柄
    hwnd := WinGetID("A")
    ; 获取输入法状态
    ; 0x0409 = 英文(美国), 0x0804 = 中文(简体)
    locale := DllCall("GetKeyboardLayout", "UInt", DllCall("GetWindowThreadProcessId", "UInt", hwnd, "UInt", 0), "UInt")
    ; 取低16位判断语言ID
    langID := locale & 0xFFFF
    ; 英文输入法的语言ID通常是 0x0409 (1033) 或 0x0809 (2057)
    return (langID = 0x0409 or langID = 0x0809)
}

; 检查空闲时间并切换到英文输入法
CheckIdleTime() {
    global lastInputTime, autoSwitchEnabled
    
    ; 如果自动切换功能未启用，直接返回
    if (!autoSwitchEnabled) {
        return
    }
    
    idleTime := A_TickCount - lastInputTime
    
    ; 如果空闲时间超过10秒（10000毫秒），且当前不是英文输入法，则切换
    if (idleTime >= 10000) {
        if (!IsEnglishIME()) {
            Send("#{Space}")  ; 切换输入法
        }
        lastInputTime := A_TickCount  ; 重置计时器避免重复检查
    }
}

; Ctrl+Alt+Shift+A 切换自动切换功能
^!+a:: {
    global autoSwitchEnabled
    autoSwitchEnabled := !autoSwitchEnabled
    
    if (autoSwitchEnabled) {
        TrayTip("自动切换已启用", "10秒无输入将自动切换到英文输入法", 1)
    } else {
        TrayTip("自动切换已禁用", "不会自动切换输入法", 1)
    }
}

CapsLock:: {
    ResetInputTimer()  ; CapsLock 按键也算输入
    
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