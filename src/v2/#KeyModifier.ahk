#Requires AutoHotkey v2.0+
#SingleInstance Force
Persistent()
CoordMode "Mouse", "Client"
; #Include <KeyBinding>
#Include <HelpGui>

#Include <ClickMacro>
#Include <KeyModifier>
#Include <StatusOverlay>

; BindingScript("#KeyModifier", GetScriptStatus)
+Space:: Send("_")
XButton1:: Send("{F10}")
XButton2:: Send("{F11}")
KeyMod_ShowHelpUI()

KeyMod_ShowHelpUI(hideTimer := 0) {
    sections := [{
        title: "🖥️ MONITOR & PEN SETTINGS",
        lines: [
            "Shift+Alt+1..3`t→ Cấu hình màn hình (XP-Table)",
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
            "Pause`t`t→ Pause/Continue Script"
        ]
    }, {
        title: "🔧 ADDITIONAL FEATURES",
        lines: [
            "Ctrl+Shift+C`t→ Mở cài đặt về cấu hình khác",
            "Ctrl+Shift+P`t→ Tùy chỉnh phím tắt",
            "Ctrl+Shift+S`t→ Lưu cấu hình hiện tại"
        ]
    }, {
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
    }]

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