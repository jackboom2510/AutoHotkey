#Include <core\UserFuncs>
ConfigureMonitorSettings(option) {
    MouseGetPos(&mouseX, &mouseY)
    RunIfNotExist("C:\Program Files\XPPen\PenTablet.exe", "PenTablet.exe")
    WinActivate("ahk_exe PenTablet.exe")
    ClickAndSleep(55, 135)
    ClickAndSleep(515, 530)
    ClickAndSleep(285, 445)
    if (option = 1) {
        ClickAndSleep(285, 490)
    }
    else if (option = 2) {
        ClickAndSleep(285, 530)
    }
    else if (option = 3) {
        ClickAndSleep(285, 565)
    }
    ClickAndSleep(150, 100, 100)
    WinClose("ahk_exe PenTablet.exe")
    MouseMove(mouseX, mouseY)
}
ConfigurePenSettings(option) {
    MouseGetPos(&mouseX, &mouseY)
    RunIfNotExist("C:\Program Files\XPPen\PenTablet.exe", "PenTablet.exe")
    WinActivate("ahk_exe PenTablet.exe")
    ClickAndSleep(60, 230)
    if (option = 1) {
        ClickAndSleep(685, 320)
    }
    else if (option = 2) {
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
            ClickAndSleep(1000, 515, 3 * timer)
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
        case 1:
            ClickAndSleep(267, 87, 0)
        case 2:
            ClickAndSleep(297, 87, 0)
        case 3:
            ClickAndSleep(327, 87, 0)
        case 4:
            ClickAndSleep(357, 87, 0)
        case 5:
            ClickAndSleep(377, 87, 0)
    }
    MouseMove(mouseX, mouseY)
}