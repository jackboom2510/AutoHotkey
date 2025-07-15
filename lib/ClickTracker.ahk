class ClickTracker {
    static clicks := []
    static isTracking := false
    static gui := ""
    static lastCode := ""
    static editBox := ""
    static targetWinTitle := ""
    static targetWinID := 0
    static targetWinExe := ""
    static targetWinPos := { x: 0, y: 0, w: 0, h: 0 }

    __New() {
        ClickTracker.gui := Gui("+AlwaysOnTop -Resize -DPIScale", "Mouse Click Tracker")
        ClickTracker.gui.BackColor := "E0FFFF"
        ClickTracker.gui.SetFont("s12", "Segoe UI")

        ClickTracker.btnStart := ClickTracker.gui.Add("Button", "x15 y5 w150", "Bắt đầu")
        ClickTracker.btnStop := ClickTracker.gui.Add("Button", "x+5 w150 Hidden", "Kết thúc")
        ClickTracker.btnTest1 := ClickTracker.gui.Add("Button", "x+5 w100", "Test 1")
        ClickTracker.btnDefault := ClickTracker.gui.Add("Button", "xm y+10 w100", "Default")
        ClickTracker.btnCopy := ClickTracker.gui.Add("Button", "x+3 yp w100", "Copy")
        ClickTracker.btnExport := ClickTracker.gui.Add("Button", "x+3 w100", "Export")
        ClickTracker.btnTest2 := ClickTracker.gui.Add("Button", "x+5 w100", "Test 2")

        ClickTracker.editBox := ClickTracker.gui.Add("Edit", "xm y+10 w400 r12 -Wrap")

        ClickTracker.btnStart.OnEvent("Click", (*) => ClickTracker.StartTracking())
        ClickTracker.btnStop.OnEvent("Click", (*) => ClickTracker.StopTracking())
        ClickTracker.btnCopy.OnEvent("Click", (*) => ClickTracker.CopyScript())
        ClickTracker.btnExport.OnEvent("Click", (*) => ClickTracker.ExportScript())
        ClickTracker.btnTest1.OnEvent("Click", (*) => ClickTracker.RunTestAbsolute())
        ClickTracker.btnTest2.OnEvent("Click", (*) => ClickTracker.RunTestRelative())
        ClickTracker.btnDefault.OnEvent("Click", (*) => ClickTracker.RestoreScript())

        ClickTracker.gui.Show("AutoSize")
    }
    static Toggle() {
        if !ClickTracker.gui {
            ClickTracker()
            return
        }

        hwnd := ClickTracker.gui.Hwnd

        if !WinExist("ahk_id " hwnd) {
            ClickTracker.gui.Show("AutoSize")
            return
        }

        winState := WinGetMinMax("ahk_id " hwnd)

        if winState = -1
            ClickTracker.gui.Show("AutoSize")
        else
            ClickTracker.gui.Hide()
    }

    static ToggleTracking() {
        if ClickTracker.isTracking = true {
            ClickTracker.StopTracking()
        } else {
            ClickTracker.StartTracking()
        }
    }

    static StartTracking() {
        ClickTracker.isTracking := !ClickTracker.isTracking
        ClickTracker.clicks := []
        ClickTracker.targetWinTitle := ""
        ClickTracker.targetWinID := 0
        ClickTracker.targetWinPos := { x: 0, y: 0, w: 0, h: 0 }
        ClickTracker.btnStart.Visible := false
        ClickTracker.btnStop.Visible := true
        TrayTip("Start", "Start Tracking .", 2)
        ClickTracker.gui.Minimize()
    }

    static StopTracking() {
        ClickTracker.isTracking := !ClickTracker.isTracking
        ClickTracker.btnStart.Visible := true
        ClickTracker.btnStop.Visible := false
        ClickTracker.UpdateEditBox()
        TrayTip("Stop", "Stop Tracking.", 2)
        ClickTracker.gui.Show()
        WinActivate(ClickTracker.gui.Hwnd)
    }


    static Track() {
        if !ClickTracker.isTracking
            return

        MouseGetPos &x, &y, &winHwnd

        if ClickTracker.clicks.Length = 0 {
            title := WinGetTitle(Format("ahk_id {}", winHwnd))
            wx := wy := ww := wh := 0
            WinGetPos(&wx, &wy, &ww, &wh, Format("ahk_id {}", winHwnd))

            ClickTracker.targetWinExe := WinGetProcessName(Format("ahk_id {}", winHwnd))
            ClickTracker.targetWinTitle := title
            ClickTracker.targetWinID := winHwnd
            ClickTracker.targetWinPos := { x: wx, y: wy, w: ww, h: wh }
        }

        ClickTracker.clicks.Push({ x: x, y: y })
        SoundBeep 800
    }

    static UpdateEditBox() {
        code := ""

        code .= "ReplayTest1() {" "`n"
        if (ClickTracker.targetWinTitle != "") {
            code .= Format('    WinActivate("ahk_exe {}")`n    Sleep(500)`n', ClickTracker.targetWinExe)
            code .= '    screenW := ' SysGet(78) '`n    screenH := ' SysGet(79) '`n'
        }
        for pt in ClickTracker.clicks {
            posX := pt.x + ClickTracker.targetWinPos.x
            posY := pt.y + ClickTracker.targetWinPos.y
            code .= Format("    ClickAndSleep({}, {})`n", posX, posY)
        }
        code .= "}`n`n"

        code .= "ReplayTest2() {" "`n"
        if (ClickTracker.targetWinTitle != "") {
            code .= Format('    WinActivate("ahk_exe {}")`n    Sleep(500)`n', ClickTracker.targetWinExe)
            code .= '    screenW := ' A_ScreenWidth '`n    screenH := ' A_ScreenHeight '`n'
            code .= '    windowX := ' ClickTracker.targetWinPos.x '`n'
            code .= '    windowY := ' ClickTracker.targetWinPos.y '`n'
            code .= '    windowW := ' ClickTracker.targetWinPos.w '`n'
            code .= '    windowH := ' ClickTracker.targetWinPos.h '`n'

        }
        for pt in ClickTracker.clicks {
            posX := pt.x
            posY := pt.y
            code .= Format("    ClickAndSleep({}, {})`n", posX, posY)
        }
        code .= "}`n`n"

        code .= "ClickAndSleep(x, y, delay := 200) {" "`n"
        code .= "    Click(x, y)" "`n"
        code .= "    Sleep(delay)" "`n"
        code .= "}"

        ClickTracker.editBox.Value := code
        ClickTracker.lastCode := code
    }

    static CopyScript() {
        A_Clipboard := ClickTracker.editBox.Value
        TrayTip("Đã sao chép!", "Mã mô phỏng đã được copy vào clipboard.", 1)
    }

    static RestoreScript() {
        if (ClickTracker.lastCode != "") {
            ClickTracker.editBox.Value := ClickTracker.lastCode
            TrayTip("Đã phục hồi", "Đã trở về code lúc kết thúc theo dõi.", 2)
        } else {
            MsgBox "Chưa có code để phục hồi! Vui lòng thực hiện theo dõi chuột trước."
        }
    }

    static ExportScript() {
        filePath := "C:\Users\jackb\Documents\AutoHotkey\test\test.ahk"
        header := "#Requires AutoHotkey v2.0.18+" "`n" "#SingleInstance Force" "`n" "Persistent()" "`n`n"
        FileDelete filePath
        FileAppend header, filePath
        FileAppend ClickTracker.editBox.Value, filePath
        TrayTip("Xuất file thành công", "File đã được lưu: " filePath, 2)
    }

    static RunTestAbsolute() {

        screenWidth := SysGet(78)
        screenHeight := SysGet(79)

        testGui := Gui("+AlwaysOnTop +ToolWindow +LastFound -DPIScale", "Test Overlay")
        testGui.BackColor := "White"
        WinSetTransparent(150)
        testGui.Show("x0 y0 w" screenWidth " h" screenHeight)

        for click in ClickTracker.clicks {
            posX := click.x + ClickTracker.targetWinPos.x
            posY := click.y + ClickTracker.targetWinPos.y
            ClickTracker.DrawRedX(testGui, posX, posY)
            ClickTracker.ClickAndSleep(posX, posY, 300)
        }

        Sleep(1000)
        testGui.Destroy()
    }

    static RunTestRelative() {

        win := ClickTracker.targetWinID
        if !win {
            MsgBox "Chưa có thông tin cửa sổ!"
            return
        }

        x := ClickTracker.targetWinPos.x, y := ClickTracker.targetWinPos.y
        w := ClickTracker.targetWinPos.w, h := ClickTracker.targetWinPos.h

        testGui := Gui("+AlwaysOnTop +ToolWindow +LastFound -DPIScale", "Test Overlay (Window Based)")
        testGui.BackColor := "White"
        WinSetTransparent(150)
        testGui.Show("x" x " y" y " w" w " h" h)

        for click in ClickTracker.clicks {
            relX := click.x
            relY := click.y
            ClickTracker.DrawRedX(testGui, relX, relY)
            ClickTracker.ClickAndSleep(relX, relY, 300)
        }

        Sleep(1000)
        testGui.Destroy()
    }

    static DrawRedX(gui, x, y) {
        color := "Red"
        size := 3
        for offset in ClickTracker.Range(-size, size)
            ClickTracker.DrawSquare(gui, x + offset, y + offset, 2, color)
        for offset in ClickTracker.Range(-size, size)
            ClickTracker.DrawSquare(gui, x + offset, y - offset, 2, color)

        textX := x + size + 5
        textY := y - 7

        gui.Add("Text", Format("x{} y{} w100 h15", textX, textY), Format("({}, {})", x, y))
    }

    static DrawSquare(gui, cx, cy, halfSize, color) {
        for dx in ClickTracker.Range(-halfSize, halfSize) {
            for dy in ClickTracker.Range(-halfSize, halfSize) {
                gui.Add("Text", Format("x{} y{} w1 h1 Background{}", cx + dx, cy + dy, color))
            }
        }
    }

    static Range(from, to) {
        result := []
        step := from <= to ? 1 : -1
        loop Abs(to - from) + 1
            result.Push(from + (A_Index - 1) * step)
        return result
    }

    static ClickAndSleep(x, y, clickDelay := 200) {
        Click(x, y)
        Sleep(clickDelay)
    }
}
ClickTracker