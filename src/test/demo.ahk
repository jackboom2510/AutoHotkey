; ================================
; Temporary Pinned Window System
; AHK v2.0.18+
; ================================
#Requires AutoHotkey v2.0.18+
#SingleInstance Force
Persistent

global PinnedWinID := 0
global ExternalClickCount := 0
global RequiredClicks := 3    ; Số lần click vào cửa sổ khác để bỏ ghim

TrayTip('Start Demo')
; --------------------------------
; Hotkey để ghim cửa sổ hiện tại
; --------------------------------
!`:: {   ; Ctrl + Alt + P
    global PinnedWinID
    PinnedWinID := WinGetID("A")
    ExternalClickCount := 0
    TrayTip("Pinned!", "Đã ghim cửa sổ: " WinGetTitle(PinnedWinID), 1000)
}

; --------------------------------
; Hook chuột để theo dõi click
; --------------------------------
; Low-Level Mouse Hook
OnMessage(0x0201, OnLButtonDown) ; WM_LBUTTONDOWN
OnMessage(0x0204, OnRButtonDown) ; WM_RBUTTONDOWN

OnLButtonDown(wParam, lParam, msg, hwnd) {
    HandleClick()
}
OnRButtonDown(wParam, lParam, msg, hwnd) {
    HandleClick()
}

; --------------------------------
; Xử lý hành vi click chuột
; --------------------------------
HandleClick() {
    global PinnedWinID, ExternalClickCount, RequiredClicks
    if (PinnedWinID = 0)
        return

    WinUnderMouse := WinGetID("ahk_id " GetMouseWinID())
    if (WinUnderMouse != PinnedWinID) {
        ExternalClickCount += 1
        DebugTooltip("Count: " ExternalClickCount)

        if (ExternalClickCount >= RequiredClicks) {
            ; --------------- REMOVE PIN ---------------
            PinnedWinID := 0
            ExternalClickCount := 0
            TrayTip("Pin removed", "Đã bỏ ghim do click đủ số lần.", 1000)
        } else {
            ; Ngăn AutoFocus–Optional: ngăn focus vào cửa sổ khác
            ; ControlFocus("ahk_id " PinnedWinID)
        }
    }
}

; --------------------------------
; Lấy WinID dưới con trỏ chuột
; --------------------------------
GetMouseWinID() {
    static pt := Buffer(8, 0)
    DllCall("GetCursorPos", "ptr", pt)
    return DllCall("WindowFromPoint", "int64", NumGet(pt, 0, "int64"))
}

; Optional: debug hiển thị số lần click
DebugTooltip(text) {
    ToolTip(text, 10, 10)
    SetTimer(() => ToolTip(), -500)
}

Esc:: {
    TrayTip('Exit Demo')
    ExitApp()
}
