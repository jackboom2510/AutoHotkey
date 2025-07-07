#Requires AutoHotkey v2.0.18+
#Include "lib\KeyModifier.ahk"
#Include "lib\DeviceConfig.ahk"
#Include "lib\HelpGui.ahk"
#SingleInstance Force
Persistent()
CoordMode "Mouse", "Client"

;@Ahk2Exe-AddResource C:\Users\jackb\Documents\AutoHotkey\icon\settings.ico
;@Ahk2Exe-ExeName C:\Users\jackb\Documents\AutoHotkey\%A_ScriptName%.exe

;   ====================================== Configurations ======================================
+!1:: ConfigureMonitorSettings(2)
+!2:: ConfigureMonitorSettings(3)
+!3:: ConfigureMonitorSettings(1)
+!q:: ConfigurePenSettings(1)
+!e:: ConfigurePenSettings(2)
^!c:: ConfigureDrawboardPDF(1)
^!+c:: ConfigureDrawboardPDF(2)
Pause:: Pause -1

F20:: ToggleAndSend(20, "1", "2")
F21:: ToggleAndExcute(21, () => ConfigureOneNote(2), () => ConfigureOneNote(3))
F22:: ToggleAndSend(22, "^+2", "^+3")
F23:: ToggleAndSend(23, "{Space}", "{1}")
F24:: ToggleAndSend(24, "v", "h")

#HotIf (isScriptEnabled)
Space:: ToggleAndExcute(15, () => ConfigureOneNote(1), () => ConfigureOneNote(2))
^Space:: ToggleAndExcute(15, () => ConfigureOneNote(1), () => ConfigureOneNote(5))
1:: ConfigureOneNote(1)
2:: ConfigureOneNote(2)
3:: ConfigureOneNote(3)
4:: ConfigureOneNote(4)

^!w:: Send("{PgUp}")
^!s:: Send("{PgDn}")
!w:: Send("{WheelUp}")
!s:: Send("{WheelDown}")
!a:: Send("{WheelLeft}")
!d:: Send("{WheelRight}")
w:: Send "{Up}"
a:: Send "{Left}"
s:: Send "{Down}"
d:: Send "{Right}"
!q:: Send "!{-}"
!e:: Send "!{=}"
^q:: Send "^{-}"
^e:: Send "^{=}"
^!q:: Send "^{WheelDown}"
^!e:: Send "^{WheelUp}"
#HotIf

!F1:: {
    global toggle, currentKey

    toggle := !toggle
    if toggle {
        result := InputBox("Nhập phím bạn muốn gửi liên tục:", "Nhập phím", "w300 h150")
        if result.Result != "OK" || result.Value = "" {
            toggle := false
            return
        }
        currentKey := FormatSendKeys(result.Value)
        ToolTip("Gửi tự động phím: " . currentKey)
        SetTimer(AutoSendKey, 1000)
    } else {
        ToolTip("Dừng gửi phím: " . currentKey)
        SetTimer(AutoSendKey, 0)
    }
    SetTimer(HideToolTip, -1500)
}

^!x:: {
    global isScriptEnabled
    ShowStatusOverlay(isScriptEnabled := !isScriptEnabled)
}

^!z:: {
    global isOverlayVisible
    isOverlayVisible := !isOverlayVisible
    if isOverlayVisible {
        ShowStatusOverlay(isScriptEnabled)
    } else {
        HideStatusOverlay()
    }
}

#^c:: {
    hwnd := WinActive("A")
    if !hwnd {
        MsgBox("Không tìm thấy cửa sổ đang hoạt động.", "Lỗi", 48)
        return
    }

    pid := WinGetPID(hwnd)

    try {
        exePath := ProcessGetPath(pid)
        SplitPath exePath, , &dir  ; Lấy thư mục chứa file exe
        A_Clipboard := dir
        ToolTip("Đã copy: " . dir)
    } catch {
        MsgBox("Không thể lấy đường dẫn tiến trình.", "Lỗi", 48)
    }

    SetTimer(() => ToolTip(), -1500)
}

;   ======================================== Tray Menu ========================================
KeyMod_InitTrayMenu()
KeyMod_ShowHelpUI(5)

KeyMod_InitTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Help", (*) => KeyMod_ShowHelpUI())
    A_TrayMenu.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
    A_TrayMenu.Add()
    A_TrayMenu.Add("Reload Script", (*) => Reload())
    A_TrayMenu.Add("Edit Script", (*) => Edit())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Suspend Hotkeys", (*) => ToggleSuspend())
    A_TrayMenu.Add("Pause Script", (*) => TogglePause())
    A_TrayMenu.Add("Exit", (*) => ExitApp())

    A_TrayMenu.Default := "Help"
    A_TrayMenu.ClickCount := 1
}

KeyMod_ShowHelpUI(hideTimer := 0) {
    sections := [{
        title: "🖥️ MONITOR & PEN SETTINGS",
        lines: [
            "Shift+Alt+1`t→ Cấu hình màn hình số 2 (XP-Table)",
            "Shift+Alt+2`t→ Cấu hình màn hình số 3",
            "Shift+Alt+3`t→ Cấu hình màn hình số 1",
            "Shift+Alt+Q`t→ Pen Settings 1",
            "Shift+Alt+E`t→ Pen Settings 2",
            "Shift+Alt+D`t→ Cấu hình Drawboard PDF",
            "Alt+1..4`t→ Cấu hình OneNote (1–4)"
        ]
    }, {
        title: "🔁 AUTO SEND",
        lines: [
            "Alt+F1`t→ Nhập và tự động gửi một phím mỗi giây (toggle)"
        ]
    }, {
        title: "🎛 TOGGLE KEYS",
        lines: [
            "F21`t→ 1 / 2",
            "F21`t→ Alt+1 / Alt+2",
            "F22`t→ Ctrl+Shift+2 / Ctrl+Shift+3",
            "F23`t→ Space / 1",
            "F24`t→ v / h"
        ]
    }, {
        title: "📋 UTILITIES",
        lines: [
            "Ctrl+Win+C`t→ Copy thư mục tiến trình",
            "Ctrl+Alt+X`t→ Bật/tắt toàn bộ script",
            "Ctrl+Alt+Z`t→ Bật/tắt overlay trạng thái",
            "Pause`t`t→ Pause/Continue Script",
        ]
    }]

    ShowHelp("🧩 Script Hotkey Help", sections, hideTimer)
}

PgUp:: return
+PgUp:: return
^PgUp:: return
!PgUp:: return
#PgUp:: return
^+PgUp:: return
^!PgUp:: return
!+PgUp:: return
#+PgUp:: return
#^PgUp:: return
#!PgUp:: return
^!+PgUp:: return
^!#PgUp:: return
>^PgUp:: return

PgDn:: return
+PgDn:: return
^PgDn:: return
!PgDn:: return
#PgDn:: return
^+PgDn:: return
^!PgDn:: return
!+PgDn:: return
#+PgDn:: return
#^PgDn:: return
#!PgDn:: return
^!+PgDn:: return
^!#PgDn:: return