CoordMode "Mouse"
class ClickTrackerUI {
    gui := unset
    guiID := ""
    guiOpts := "+AlwaysOnTop -Resize -DPIScale"
    ShowOpts := ""
    name := "Mouse Click Tracker"
    clicks := []
    isTracking := false
    lastCode := ""
    editBox := ""
    targetWinTitle := ""
    targetWinID := 0
    targetWinExe := ""
    targetWinPos := { x: 0, y: 0, w: 0, h: 0 }

    __New() {
        if(this.guiID) {
            if(WinExist(this.name " ahk_id " this.guiID))
        }
        this.gui := Gui(this.guiOpts, this.name)
        this.guiID := this.gui.hwnd
        this.gui.BackColor := "E0FFFF"
        this.gui.SetFont("s12", "Segoe UI")

        this.btnStart := this.gui.Add("Button", "x15 y5 w150", "Bắt đầu")
        this.btnStop := this.gui.Add("Button", "x+5 w150 Hidden", "Kết thúc")
        this.btnTest1 := this.gui.Add("Button", "x+5 w100", "Test 1")
        this.btnDefault := this.gui.Add("Button", "xm y+10 w100", "Default")
        this.btnCopy := this.gui.Add("Button", "x+3 yp w100", "Copy")
        this.btnExport := this.gui.Add("Button", "x+3 w100", "Export")
        this.btnTest2 := this.gui.Add("Button", "x+5 w100", "Test 2")

        this.editBox := this.gui.Add("Edit", "xm y+10 w400 r12 -Wrap")

        this.btnStart.OnEvent("Click", (*) => this.StartTracking())
        this.btnStop.OnEvent("Click", (*) => this.StopTracking())
        this.btnCopy.OnEvent("Click", (*) => this.CopyScript())
        this.btnExport.OnEvent("Click", (*) => this.ExportScript())
        this.btnTest1.OnEvent("Click", (*) => this.RunTestAbsolute())
        this.btnTest2.OnEvent("Click", (*) => this.RunTestRelative())
        this.btnDefault.OnEvent("Click", (*) => this.RestoreScript())

        this.Show()
    }
    Toggle() {
        if !WinActive("ahk_id " this.guiID) 
            this.Hide()
        else
            this.Show()
    }
    Show() {
        this.gui.Show(this.ShowOpts)
    }
    Hide() {
        this.gui.Hide()
    }
    ToggleTracking() {
        if this.isTracking = true {
            this.StopTracking
        } else {
            this.StartTracking
        }
    }
    StartTracking() {
        this.Hide()
        this.isTracking := !this.isTracking
        this.clicks := []
        this.targetWinTitle := ""
        this.targetWinID := 0
        this.targetWinPos := { x: 0, y: 0, w: 0, h: 0 }
        this.btnStart.Visible := false
        this.btnStop.Visible := true
        TrayTip("Start", "Start Tracking .", 2)
    }
    StopTracking() {
        this.isTracking := !this.isTracking
        this.btnStart.Visible := true
        this.btnStop.Visible := false
        this.UpdateEditBox()
        TrayTip("Stop", "Stop Tracking.", 2)
        this.gui.Show()
        WinActivate(this.gui.Hwnd)
    }
    Track() {
        if !this.isTracking
            return
        MouseGetPos &x, &y, &winHwnd
        if this.clicks.Length = 0 {
            title := WinGetTitle(Format("ahk_id {}", winHwnd))
            WinGetPos(&wx, &wy, &ww, &wh, Format("ahk_id {}", winHwnd))
            this.targetWinExe := WinGetProcessName(Format("ahk_id {}", winHwnd))
            this.targetWinTitle := title
            this.targetWinID := winHwnd
            this.targetWinPos := { x: wx, y: wy, w: ww, h: wh }
        }
        this.clicks.Push({ x: x, y: y })
        SoundBeep 800
    }

    UpdateEditBox() {
        code := ""
        code .= "ReplayTest1() {" "`n"
        if (this.targetWinTitle != "") {
            code .= Format('    WinActivate("ahk_exe {}")`n    Sleep(500)`n', this.targetWinExe)
            code .= '    screenW := ' SysGet(78) '`n    screenH := ' SysGet(79) '`n'
        }
        for pt in this.clicks {
            posX := pt.x + this.targetWinPos.x
            posY := pt.y + this.targetWinPos.y
            code .= Format("    ClickAndSleep({}, {})`n", posX, posY)
        }
        code .= "}`n`n"

        code .= "ReplayTest2() {" "`n"
        if (this.targetWinTitle != "") {
            code .= Format('    WinActivate("ahk_exe {}")`n    Sleep(500)`n', this.targetWinExe)
            code .= '    screenW := ' A_ScreenWidth '`n    screenH := ' A_ScreenHeight '`n'
            code .= '    windowX := ' this.targetWinPos.x '`n'
            code .= '    windowY := ' this.targetWinPos.y '`n'
            code .= '    windowW := ' this.targetWinPos.w '`n'
            code .= '    windowH := ' this.targetWinPos.h '`n'

        }
        for pt in this.clicks {
            posX := pt.x
            posY := pt.y
            code .= Format("    ClickAndSleep({}, {})`n", posX, posY)
        }
        code .= "}`n`n"

        code .= "ClickAndSleep(x, y, delay := 200) {" "`n"
        code .= "    Click(x, y)" "`n"
        code .= "    Sleep(delay)" "`n"
        code .= "}"

        this.editBox.Value := code
        this.lastCode := code
    }

    CopyScript() {
        A_Clipboard := this.editBox.Value
        TrayTip("Đã sao chép!", "Mã mô phỏng đã được copy vào clipboard.", 1)
    }

    RestoreScript() {
        if (this.lastCode != "") {
            this.editBox.Value := this.lastCode
            TrayTip("Đã phục hồi", "Đã trở về code lúc kết thúc theo dõi.", 2)
        } else {
            MsgBox "Chưa có code để phục hồi! Vui lòng thực hiện theo dõi chuột trước."
        }
    }
    ExportScript() {
        filePath := "C:\Users\jackb\Documents\AutoHotkey\test\test.ahk"
        header := "#Requires AutoHotkey v2.0.18+" "`n" "#SingleInstance Force" "`n" "Persistent()" "`n`n"
        FileDelete filePath
        FileAppend header, filePath
        FileAppend this.editBox.Value, filePath
        TrayTip("Xuất file thành công", "File đã được lưu: " filePath, 2)
    }

    RunTestAbsolute() {
        screenWidth := SysGet(78)
        screenHeight := SysGet(79)
        testGui := Gui("+AlwaysOnTop +ToolWindow +LastFound -DPIScale", "Test Overlay")
        testGui.BackColor := "White"
        WinSetTransparent(150)
        testGui.Show("x0 y0 w" screenWidth " h" screenHeight)

        for click in this.clicks {
            posX := click.x + this.targetWinPos.x
            posY := click.y + this.targetWinPos.y
            this.DrawRedX(testGui, posX, posY)
            this.ClickAndSleep(posX, posY, 300)
        }

        Sleep(1000)
        testGui.Destroy()
    }

    RunTestRelative() {

        win := this.targetWinID
        if !win {
            MsgBox "Chưa có thông tin cửa sổ!"
            return
        }

        x := this.targetWinPos.x, y := this.targetWinPos.y
        w := this.targetWinPos.w, h := this.targetWinPos.h

        testGui := Gui("+AlwaysOnTop +ToolWindow +LastFound -DPIScale", "Test Overlay (Window Based)")
        testGui.BackColor := "White"
        WinSetTransparent(150)
        testGui.Show("x" x " y" y " w" w " h" h)

        for click in this.clicks {
            relX := click.x
            relY := click.y
            this.DrawRedX(testGui, relX, relY)
            this.ClickAndSleep(relX, relY, 300)
        }

        Sleep(1000)
        testGui.Destroy()
    }

    DrawRedX(gui, x, y) {
        color := "Red"
        size := 3
        for offset in this.Range(-size, size)
            this.DrawSquare(gui, x + offset, y + offset, 2, color)
        for offset in this.Range(-size, size)
            this.DrawSquare(gui, x + offset, y - offset, 2, color)

        textX := x + size + 5
        textY := y - 7

        gui.Add("Text", Format("x{} y{} w100 h15", textX, textY), Format("({}, {})", x, y))
    }

    DrawSquare(gui, cx, cy, halfSize, color) {
        for dx in this.Range(-halfSize, halfSize) {
            for dy in this.Range(-halfSize, halfSize) {
                gui.Add("Text", Format("x{} y{} w1 h1 Background{}", cx + dx, cy + dy, color))
            }
        }
    }

    Range(from, to) {
        result := []
        step := from <= to ? 1 : -1
        loop Abs(to - from) + 1
            result.Push(from + (A_Index - 1) * step)
        return result
    }

    ClickAndSleep(x, y, clickDelay := 200) {
        Click(x, y)
        Sleep(clickDelay)
    }
}

