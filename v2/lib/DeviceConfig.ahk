#Include "log.ahk"

RunIfNotExist(exePathOrShellCmd, exeName, isUWP := false) {
    if !WinExist("ahk_exe " exeName) {
        Run(isUWP ? "explorer shell:AppsFolder\" exePathOrShellCmd : exePathOrShellCmd)
        if !WinWait("ahk_exe " exeName, , 7) {
            MsgBox("❌ Không thể khởi động hoặc tìm thấy cửa sổ: " exeName)
            return false
        }
    }
    return true
}

;	=== Mouse Move ===
ClickAndSleep(x, y, clickDelay := 200) {
    Click(x, y)
    Sleep(clickDelay)
}

logClick(x, y, clickDelay := 200, label := "") {
    ToolTip("➡️ Moving to: " label " (X: " x ", Y: " y ")")
    MouseMove(x, y, 50)
    Sleep(clickDelay * 10)
    Click(x, y)
    ToolTip("✅ Clicked: " label " (X: " x ", Y: " y ")")
    Sleep(clickDelay)  ; Adjust for the log wait time
    ToolTip()
    log("Clicked at: " label " (" x ", " y ") with delay: " clickDelay)
}

log(text) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    FileAppend "[" timestamp "] " text "`n", logFile
}

;	=== Configuration ===
ConfigureMonitorSettings(option) {
    MouseGetPos(&mouseX, &mouseY)

    ; Mở phần mềm nếu chưa mở
    RunIfNotExist("C:\Program Files\XPPen\PenTablet.exe", "PenTablet.exe")
    WinActivate("ahk_exe PenTablet.exe")

    ; Click các vị trí cơ bản mà không cần Sleep sau click
    ClickAndSleep(55, 135)
    ClickAndSleep(515, 530)
    ClickAndSleep(285, 445)

    ; Chọn Option với Sleep sau click
    if (option = 1) {
        ClickAndSleep(285, 490)
    }
    else if (option = 2) {
        ClickAndSleep(285, 530)
    }
    else if (option = 3) {
        ClickAndSleep(285, 565)
    }

    ; Quay lại và đóng ứng dụng
    ClickAndSleep(150, 100, 100)
    WinClose("ahk_exe PenTablet.exe")
    MouseMove(mouseX, mouseY)
}

ConfigurePenSettings(option) {
    MouseGetPos(&mouseX, &mouseY)

    ; Mở phần mềm nếu chưa mở
    RunIfNotExist("C:\Program Files\XPPen\PenTablet.exe", "PenTablet.exe")
    WinActivate("ahk_exe PenTablet.exe")

    ; Click vào "Pen Settings"
    ClickAndSleep(60, 230)

    ; Tùy chọn Window Ink hoặc Mouse Mod
    if (option = 1) {
        ; Chọn Window Ink (685:320)
        ClickAndSleep(685, 320)
    }
    else if (option = 2) {
        ; Chọn Mouse Mod (685:360)
        ClickAndSleep(685, 360)
        ClickAndSleep(60, 230)
    }
    WinClose("ahk_exe PenTablet.exe")
    MouseMove(mouseX, mouseY)
}

ConfigureDrawboardPDF(option, timer := 350, loopCnt := 24) {
    MouseGetPos(&mouseX, &mouseY)

    winTitle := "Drawboard PDF"
    WinActivate(winTitle)
    WinGetPos(&x, &y, &w, &h, winTitle)
    centerX := x + w // 2
    centerY := y + h // 2
    MouseMove(centerX, centerY)
    MouseClick("R", centerX, centerY)
    Sleep(300)
    ClickAndSleep(centerX + 150, centerY + 375)
    if (option = 1)
        Send "{Delete}"
    else if (option = 2) {
        loop loopCnt {
            ClickAndSleep(625, 850, timer)
            ClickAndSleep(1000, 515, 3*timer)
            Send "{Right}"
            Sleep(timer)
            MouseMove(centerX, centerY)
            MouseClick("R", centerX, centerY)
            Sleep(timer)
            ClickAndSleep(centerX + 150, centerY + 375, timer)
        }
    }

    MouseMove(mouseX, mouseY)
}

ConfigureOneNote(option) {
    RunIfNotExist("C:\Program Files\Microsoft Office\root\Office16\ONENOTE.EXE", "ONENOTE.EXE")
    WinActivate("ahk_exe ONENOTE.EXE")
    MouseGetPos(&mouseX, &mouseY)
    switch option {
        case 2:
            ClickAndSleep(265, 90, 0)
        case 3:
            ClickAndSleep(205, 90, 0)
        case 4:
            ClickAndSleep(175, 90, 0)
        default:
            ClickAndSleep(295, 90, 0)
    }
    MouseMove(mouseX, mouseY)
}
