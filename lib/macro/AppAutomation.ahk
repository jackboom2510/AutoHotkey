#Include <core\UserFuncs>
#Include <core\Core>
; ==============================================================================
; AHK v2 Script: Flexible Application Configuration Dispatcher
; This script provides functions to configure various applications (like
; XPPen, Drawboard PDF, OneNote, Samsung Notes) based on mouse clicks.
; The new FlexConfigure function determines the active window and dispatches
; the requested configuration option.
; ==============================================================================
; --- Configuration Functions (Standardized Framework) ---
ConfigureMonitorSettings(option) {
    ; --- Standard Preamble ---
    old_coordmode := A_CoordModeMouse
    CoordMode 'Mouse', 'Client'
    MouseGetPos(&mouseX, &mouseY)

    ; --- App Activation ---
    tablet_path := "C:\Program Files\XPPen\PenTablet.exe"
    tablet_process := "PenTablet.exe"
    RunIfNotExist(tablet_path, tablet_process)

    ; --- Configuration Logic ---
    ClickAndSleep(55, 135)   ; Click 'Work Area' tab
    ClickAndSleep(515, 530)  ; Click 'Screen Ratio'
    ClickAndSleep(285, 445)  ; Click Monitor Dropdown

    switch option {
        case 1:
            ClickAndSleep(285, 490) ; Monitor 1
        case 2:
            ClickAndSleep(285, 530) ; Monitor 2
        case 3:
            ClickAndSleep(285, 565) ; Monitor 3
    }

    ; Apply and Close
    ClickAndSleep(150, 100, 100) ; Click OK/Apply (approx)
    WinClose("ahk_exe " tablet_process)

    ; --- Standard Postamble ---
    MouseMove(mouseX, mouseY)
    CoordMode 'Mouse', old_coordmode
}

ConfigurePenSettings(option) {
    ; --- Standard Preamble ---
    old_coordmode := A_CoordModeMouse
    CoordMode 'Mouse', 'Client'
    MouseGetPos(&mouseX, &mouseY)

    ; --- App Activation ---
    tablet_path := "C:\Program Files\XPPen\PenTablet.exe"
    tablet_process := "PenTablet.exe"
    RunIfNotExist(tablet_path, tablet_process)

    ; Click 'Pen Settings' tab
    ClickAndSleep(60, 230)

    ; --- Configuration Logic ---
    switch option {
        case 1:
            ClickAndSleep(685, 320) ; Option 1: Set top button
        case 2:
            ClickAndSleep(685, 360) ; Option 2: Set bottom button
            ClickAndSleep(60, 230)  ; Re-click 'Pen Settings' (if menu closes)
    }

    WinClose("ahk_exe " tablet_process)

    ; --- Standard Postamble ---
    MouseMove(mouseX, mouseY)
    CoordMode 'Mouse', old_coordmode
}

ConfigureDrawboardPDF(option, timer := 350, loopCnt := 24) {
    ; --- Standard Preamble (No CoordMode needed since it only checks window and uses RClick) ---
    MouseGetPos(&mouseX, &mouseY)

    ; --- App Activation ---
    winTitle := "Drawboard PDF"
    WinActivate(winTitle)
    WinGetPos(&x, &y, &w, &h, winTitle)
    centerX := x + w // 2
    centerY := y + h // 2

    ; --- Configuration Logic ---
    MouseMove(centerX, centerY)
    MouseClick("R", centerX, centerY) ; Right-click on the canvas
    Sleep(300)
    ClickAndSleep(centerX + 150, centerY + 375) ; Click 'Clear All Markup' (approx)

    switch option {
        case 1:
            Send "{Delete}" ; Assumed to confirm 'Clear All Markup'
        case 2:
            loop loopCnt {
                ; Complex sequence of clicks/sends for Option 2
                ClickAndSleep(625, 850, timer)
                ClickAndSleep(1000, 515, 3 * timer)
                Send "{Right}"
                Sleep(timer)
                MouseMove(centerX, centerY)
                MouseClick("R", centerX, centerY)
                Sleep(timer)
                ClickAndSleep(centerX + 150, centerY + 375, timer)
            }
    }

    ; --- Standard Postamble ---
    MouseMove(mouseX, mouseY)
    ; No CoordMode reset needed as it wasn't changed from default
}

ConfigureOneNote(option) {
    ; --- Standard Preamble ---
    old_coordmode := A_CoordModeMouse
    CoordMode 'Mouse', 'Client'
    MouseGetPos(&mouseX, &mouseY)

    ; --- App Activation ---
    onenote_path := "C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE"
    onenote_process := "ONENOTE.EXE"
    RunIfNotExist(onenote_path, onenote_process)
    ; --- Configuration Logic ---
    ; These coordinates correspond to pen/draw tool buttons in the ribbon.
    switch option {
        case 1:
            ClickAndSleep(267, 87, 0) ; Tool 1
        case 2:
            ClickAndSleep(297, 87, 0) ; Tool 2
        case 3:
            ClickAndSleep(327, 87, 0) ; Tool 3
        case 4:
            ClickAndSleep(357, 87, 0) ; Tool 4
        case 5:
            ClickAndSleep(377, 87, 0) ; Tool 5
    }

    ; --- Standard Postamble ---
    MouseMove(mouseX, mouseY)
    CoordMode 'Mouse', old_coordmode
}

ConfigureSamsungNotes(option := 1) {
    ; --- Standard Preamble ---
    old_coordmode := A_CoordModeMouse
    CoordMode 'Mouse', 'Client'
    MouseGetPos(&mouseX, &mouseY)

    ; --- App Activation ---
    app_id := "SAMSUNGELECTRONICSCoLtd.SamsungNotes_wyx1vj98g3asy!App"
    process_name := "Samsung Notes"
    RunIfNotExist(app_id, process_name, true) ; UWP app
    ; --- Configuration Logic ---
    ; These coordinates target a vertical toolbar on the right side.
    if (SysGet(80) >= 2) {
        switch option {
            case 1:
                ClickAndSleep(1580, 197, 0) ; Text
            case 2:
                ClickAndSleep(1580, 381, 0) ; Selection
            case 3:
                ClickAndSleep(1580, 234, 0) ; Pen
            case 4:
                ClickAndSleep(1580, 285, 0) ; Highlight
            case 5:
                ClickAndSleep(1580, 337, 0) ; Erase
        }
    }
    else {
        switch option {
            case 1:
                ClickAndSleep(1885, 242, 0) ; Text
            case 2:
                ClickAndSleep(1890, 483, 0) ; Selection
            case 3:
                ClickAndSleep(1893, 309, 0) ; Pen
            case 4:
                ClickAndSleep(1894, 361, 0) ; Highlight
            case 5:
                ClickAndSleep(1890, 422, 0) ; Erase
        }
    }
    ; --- Standard Postamble ---
    MouseMove(mouseX, mouseY)
    CoordMode 'Mouse', old_coordmode
}

ConfigureWhiteboard(option := 1) {
    ; --- Standard Preamble ---
    old_coordmode := A_CoordModeMouse
    CoordMode 'Mouse', 'Client'
    MouseGetPos(&mouseX, &mouseY)

    ; --- App Activation ---
    app_id := "Microsoft.Whiteboard_8wekyb3d8bbwe!Whiteboard"
    process_name := "Microsoft Whiteboard"
    RunIfNotExist(app_id, process_name, true) ; UWP app
    ; --- Configuration Logic ---
    ; These coordinates target a vertical toolbar on the right side.
    if (SysGet(80) >= 2) {
        ; Send("{Bind}!w")
        ; Sleep 100
        ; Send("{Bind}" option)
        ; Sleep(500)
        ; Send("{Bind}{Escape}")
        ClickAndSleep(893, 993, 200) ; Pen Menu
        switch option {
            case 1:
                ClickAndSleep(791, 948, 0) ; Pen #1 (White)
            case 2:
                ClickAndSleep(836, 957, 0) ; Pen #2 (Yellow)
            case 3:
                ClickAndSleep(888, 957, 0) ; Pen #3 (Red)
            case 4:
                ClickAndSleep(936, 950, 0) ; Highlight
            default:
                ClickAndSleep(791, 948, 0) ; Pen #1 (White)
        }
        ClickAndSleep(1136, 948, 0) ; Exit Pen Menu
    }
    else {
        ; Send("{Bind}!w & 1")
        ; Sleep 100
        ; Send("{Bind}" option)
        ; Sleep(500)
        ; Send("{Bind}{Escape}")
        ClickAndSleep(893, 993, 200) ; Pen Menu
        switch option {
            case 1:
                ClickAndSleep(791, 948, 0) ; Pen #1 (White)
            case 2:
                ClickAndSleep(836, 957, 0) ; Pen #2 (Yellow)
            case 3:
                ClickAndSleep(888, 957, 0) ; Pen #3 (Red)
            case 4:
                ClickAndSleep(936, 950, 0) ; Highlight
            default:
                ClickAndSleep(791, 948, 0) ; Pen #1 (White)
        }
        ClickAndSleep(1136, 948, 0) ; Exit Pen Menu
    }
    ; --- Standard Postamble ---
    MouseMove(mouseX, mouseY)
    CoordMode 'Mouse', old_coordmode
}

/**
 * Dispatches the configuration action based on the active window title.
 * @param option The configuration option (1, 2, 3, etc.) to apply.
 * @param showNotification Boolean flag (1 or 0) to enable/disable UI notifications.
 */
FlexConfigure(option := 1, showNotification := false) {
    current_window := WinGetTitle('A')
    if (InStr(current_window, "Drawboard PDF")) {
        if (showNotification)
            Notify("Configuring Drawboard PDF with option " option ".", "FlexConfig", "+ t3 ci")
        ConfigureDrawboardPDF(option)
    }
    ; Check for OneNote (using InStr for titles like "Note Title - OneNote")
    else if (InStr(current_window, "OneNote")) {
        if (showNotification)
            Notify("Configuring OneNote with option " option ".", "FlexConfig", "+ t3 ci")
        ConfigureOneNote(option)
    }
    ; Check for Samsung Notes
    else if (InStr(current_window, "Samsung Notes")) {
        if (showNotification)
            Notify("Configuring Samsung Notes with option " option ".", "FlexConfig", "+ t3 ci")
        ConfigureSamsungNotes(option)
    }
    ; Check for Microsoft Whiteboard
    else if (InStr(current_window, "Microsoft Whiteboard")) {
        if (showNotification)
            Notify("Configuring Microsoft Whiteboard with option " option ".", "FlexConfig", "+ t3 ci")
        ConfigureWhiteboard(option)
    }
    ; For PenTablet settings, we need to know whether to configure Monitor or Pen.
    ; Since the user didn't specify a way to distinguish, we'll assign arbitrary options
    ; for Monitor and Pen settings within the FlexConfigure call for demonstration.
    ; Note: These functions automatically run and activate the PenTablet.exe window.
    else if (InStr(current_window, "PenTablet")) {
        ; Assuming option 1-3 is for monitor, 4+ is for pen settings
        if (option >= 1 && option <= 3) {
            if (showNotification)
                Notify("Configuring Monitor Settings with option " option ".", "FlexConfig", "+ t3 ci")
            ConfigureMonitorSettings(option)
        }
        else if (option == 4 || option == 5) {
            ; Map option 4 -> Pen option 1, option 5 -> Pen option 2
            penOption := option - 3
            if (showNotification)
                Notify("Configuring Pen Settings with option " penOption ".", "FlexConfig", "+ t3 ci")
            ConfigurePenSettings(penOption)
        }
        else {
            if (showNotification)
                Notify("PenTablet configuration option " option " not defined.", "FlexConfig Error", "+ t5 ce")
        }
    }
    ; Default case if no recognized window is active
    else {
        if (showNotification)
            Notify("No defined configuration for active window: " current_window, "FlexConfig Error", "+ t5 ce")
    }
}
