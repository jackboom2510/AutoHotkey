#Requires AutoHotkey v2.0.18+
#Include <KeyBinding>
#Include <ClickMacro>
#Include <StatusOverlay>
#Include <KeyModifier>
#Include <HelpGUI>
#SingleInstance Force
Persistent()
CoordMode "Mouse", "Client"

Pause:: Pause -1

AssignHotkey("#^c", CopyProcessDirectory)
AssignHotkey("!F1", InputBoxForAutoSendToggle)
; AssignHotkey("Pause", Pause , , ,Pause - 1)
AssignHotkey("^!z", ToggleOverlayVisibility)
AssignHotkey("^!x", ToggleScript)

AssignHotkey("^!c", ConfigureDrawboardPDF , , ,1)
AssignHotkey("^!+c", ConfigureDrawboardPDF , , ,2)
AssignHotkey("+!1", ConfigureMonitorSettings , , ,2)
AssignHotkey("+!2", ConfigureMonitorSettings , , ,3)
AssignHotkey("+!3", ConfigureMonitorSettings , , ,1)
AssignHotkey("+!q", ConfigurePenSettings , , ,1)
AssignHotkey("+!e", ConfigurePenSettings , , ,2)
; +!1:: ConfigureMonitorSettings(2)
; +!2:: ConfigureMonitorSettings(3)
; +!3:: ConfigureMonitorSettings(1)
; +!q:: ConfigurePenSettings(1)
; +!e:: ConfigurePenSettings(2)
; ^!c:: ConfigureDrawboardPDF(1)
; ^!+c:: ConfigureDrawboardPDF(2)

AssignHotkey("F21", ToggleAndExecute , , ,21,() => ConfigureOneNote(2),() => ConfigureOneNote(3))
AssignHotkey("F20", ToggleAndSend , , ,20,1,2)
AssignHotkey("F22", ToggleAndSend , , ,22,"^+2","^+3")
AssignHotkey("F23", ToggleAndSend , , ,23,"{Space}","{1}")
AssignHotkey("F24", ToggleAndSend , , ,24,"v","h")
; F21:: ToggleAndExecute(21, () => ConfigureOneNote(2), () => ConfigureOneNote(3))
; F20:: ToggleAndSend(20, "1", "2")
; F22:: ToggleAndSend(22, "^+2", "^+3")
; F23:: ToggleAndSend(23, "{Space}", "{1}")
; F24:: ToggleAndSend(24, "v", "h")

#HotIf (isScriptEnabled)
; AssignHotkey("Space", ToggleAndExecute , , ,15,() => ConfigureOneNote(1),() => ConfigureOneNote(2))
; AssignHotkey("^Space", ToggleAndExecute , , ,15,() => ConfigureOneNote(1),() => ConfigureOneNote(5))
Space:: ToggleAndExecute(15, () => ConfigureOneNote(1), () => ConfigureOneNote(2))
^Space:: ToggleAndExecute(15, () => ConfigureOneNote(1), () => ConfigureOneNote(5))
; AssignHotkey("1", ConfigureOneNote , , ,1)
; AssignHotkey("2", ConfigureOneNote , , ,2)
; AssignHotkey("3", ConfigureOneNote , , ,3)
; AssignHotkey("4", ConfigureOneNote , , ,4)
1:: ConfigureOneNote(1)
2:: ConfigureOneNote(2)
3:: ConfigureOneNote(3)
4:: ConfigureOneNote(4)

; AssignHotkey("^!w", Send , , ,"{PgUp}")
; AssignHotkey("^!s", Send , , ,"{PgDn}")
^!w:: Send("{PgUp}")
^!s:: Send("{PgDn}")

; AssignHotkey("!w", Send , , ,"{WheelUp}")
; AssignHotkey("!s", Send , , ,"{WheelDown}")
; AssignHotkey("!a", Send , , ,"{WheelLeft}")
; AssignHotkey("!d", Send , , ,"{WheelRight}")
; AssignHotkey("w", Send , , ,"{Up}")
; AssignHotkey("a", Send , , ,"{Left}")
; AssignHotkey("s", Send , , ,"{Down}")
; AssignHotkey("d", Send , , ,"{Right}")
; AssignHotkey("!q", Send , , ,"!{-}")
; AssignHotkey("!e", Send , , ,"!{=}")
; AssignHotkey("^q", Send , , ,"^{-}")
; AssignHotkey("^e", Send , , ,"^{=}")
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
; AssignHotkey("^!q", Send , , ,"^{WheelDown}")
; AssignHotkey("^!e", Send , , ,"^{WheelUp}")
^!q:: Send "^{WheelDown}"
^!e:: Send "^{WheelUp}"
#HotIf

; !F1:: InputBoxForAutoSendToggle
; #^c:: CopyProcessDirectory
; ^!x:: overlay.ToggleScript
; ^!z:: overlay.ToggleOverlayVisibility

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
    sections := [
        {
            title: "🖥️ MONITOR & PEN SETTINGS",
            lines: [
                "Shift+Alt+1..3`t→ Cấu hình màn hình (XP-Table)",
                "Shift+Alt+Q`t→ Pen Settings 1",
                "Shift+Alt+E`t→ Pen Settings 2",
                "Shift+Alt+D`t→ Cấu hình Drawboard PDF",
                "Alt+1..4`t→ Cấu hình OneNote (1–4)"
            ]
        },
        {
            title: "🔁 AUTO SEND",
            lines: [
                "Alt+F1`t→ Nhập và tự động gửi một phím mỗi giây (toggle)"
            ]
        },
        {
            title: "🎛 TOGGLE KEYS",
            lines: [
                "F21`t→ 1 / 2",
                "F21`t→ Alt+1 / Alt+2",
                "F22`t→ Ctrl+Shift+2 / Ctrl+Shift+3",
                "F23`t→ Space / 1",
                "F24`t→ v / h"
            ]
        },
        {
            title: "📋 UTILITIES",
            lines: [
                "Ctrl+Win+C`t→ Copy thư mục tiến trình",
                "Ctrl+Alt+X`t→ Bật/tắt toàn bộ script",
                "Ctrl+Alt+Z`t→ Bật/tắt overlay trạng thái",
                "Pause`t`t→ Pause/Continue Script"
            ]
        },
        {
            title: "🔧 ADDITIONAL FEATURES",
            lines: [
                "Ctrl+Shift+C`t→ Mở cài đặt về cấu hình khác",
                "Ctrl+Shift+P`t→ Tùy chỉnh phím tắt",
                "Ctrl+Shift+S`t→ Lưu cấu hình hiện tại"
            ]
        },
        {
            title: "⚙️ HOTKEYS CONDITIONED BY SCRIPT STATUS",
            lines: [
                "Ctrl+Alt+X`t→ Bật/tắt script (kích hoạt/disable hotkeys)",
                "Khi script bật, các phím tắt sau sẽ hoạt động:",
                "  - Space`t→ ToggleOneNote (1 và 2)",
                "  - ^Space`t→ ToggleOneNote (1 và 5)",
                "  - 1..4`t→ Cấu hình OneNote (1–4)",
                "  - ^!w`t→ Send {PgUp}",
                "  - ^!s`t→ Send {PgDn}",
                "  - !w`t→ Send {WheelUp}",
                "  - !s`t→ Send {WheelDown}",
                "  - w,a,s,d`t→ Các phím mũi tên di chuyển"
            ]
        }
    ]

    ShowHelp("🧩 Script Hotkey Help", sections, hideTimer, 5)
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