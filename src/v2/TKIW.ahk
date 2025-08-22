ReplayTest1() {
    WinActivate("ahk_exe The King is Watching.exe")
    Sleep(500)
    screenW := 1600
    screenH := 900
    ClickAndSleep(1336, 624)
    ClickAndSleep(1438, 564)
    ClickAndSleep(1537, 617)
    ClickAndSleep(671, 611)
    ClickAndSleep(734, 610)
}

ReplayTest2() {
    WinActivate("ahk_exe The King is Watching.exe")
    Sleep(500)
    screenW := 1600
    screenH := 900
    windowX := 0
    windowY := 0
    windowW := 1600
    windowH := 900
    ClickAndSleep(1336, 624)
    ClickAndSleep(1438, 564)
    ClickAndSleep(1537, 617)
    ClickAndSleep(671, 611)
    ClickAndSleep(734, 610)
}

ClickAndSleep(x, y, delay := 200) {
    Click(x, y)
    Sleep(delay)
}
