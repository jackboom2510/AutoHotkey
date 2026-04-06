CoordMode "Mouse", "Screen"
tracker := NClickTracker()
class NClickTracker {
    gui := unset
    guiID := ""
    guiOpts := "+AlwaysOnTop -Resize"
    ShowOpts := ""
    name := "Mouse & Keyboard Tracker"
    events := []
    isTracking := false
    lastCode := ""
    editBox := ""
    targetWinTitle := ""
    targetWinID := 0
    targetWinExe := ""
    targetWinPos := { x: 0, y: 0, w: 0, h: 0 }
    inputHook := unset

    __New() {
        if (this.guiID) {
            if (WinExist(this.name " ahk_id " this.guiID))
                return
        }
        this.gui := Gui(this.guiOpts, this.name)
        this.guiID := this.gui.hwnd
        this.gui.BackColor := "E0FFFF"
        this.gui.SetFont("s12", "Segoe UI")

        this.btnStart := this.gui.Add("Button", "x15 y5 w150", "Bắt đầu")
        this.btnStop := this.gui.Add("Button", "x+5 w150 Hidden", "Kết thúc")
        this.btnTest1 := this.gui.Add("Button", "x+5 w100", "Test Tuyệt đối")
        this.btnDefault := this.gui.Add("Button", "xm y+10 w100", "Default")
        this.btnCopy := this.gui.Add("Button", "x+3 yp w100", "Copy")
        this.btnExport := this.gui.Add("Button", "x+3 w100", "Export")
        this.btnTest2 := this.gui.Add("Button", "x+5 w100", "Test Tương đối")

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
        if this.isTracking {
            this.StopTracking()
        } else {
            this.StartTracking()
        }
    }

    StartTracking() {
        this.Hide()
        this.isTracking := true
        this.events := []
        this.targetWinTitle := ""
        this.targetWinID := 0
        this.targetWinPos := { x: 0, y: 0, w: 0, h: 0 }
        this.btnStart.Visible := false
        this.btnStop.Visible := true

        ; Create and start the InputHook
        this.inputHook := InputHook("L1 T1")
        this.inputHook.KeyOpt("{All}", "N")
        this.inputHook.OnKeyDown := this.OnKeyDown.Bind(this)
        this.inputHook.OnMouseUp := this.OnMouseUp.Bind(this)

        this.inputHook.Start()
        TrayTip("Bắt đầu", "Bắt đầu theo dõi...", 2)
    }

    StopTracking() {
        this.isTracking := false
        this.btnStart.Visible := true
        this.btnStop.Visible := false

        ; Stop and destroy the InputHook
        if IsObject(this.inputHook) {
            this.inputHook.Stop()
            this.inputHook := unset
        }

        this.UpdateEditBox()
        TrayTip("Kết thúc", "Đã dừng theo dõi.", 2)
        this.gui.Show()
        WinActivate(this.gui.Hwnd)
    }

    OnMouseUp(inputHook, keyName) {
        if !this.isTracking
            return

        ; Only record mouse clicks, not other movements
        if (keyName == "LButton" || keyName == "RButton" || keyName == "MButton") {
            MouseGetPos &x, &y, &winHwnd
            if this.events.Length = 0 {
                title := WinGetTitle(Format('ahk_id {}', winHwnd))
                WinGetPos(&wx, &wy, &ww, &wh, Format('ahk_id {}', winHwnd))
                this.targetWinExe := WinGetProcessName(Format('ahk_id {}', winHwnd))
                this.targetWinTitle := title
                this.targetWinID := winHwnd
                this.targetWinPos := { x: wx, y: wy, w: ww, h: wh }
            }
            this.events.Push({ type: 'MouseClick', x: x, y: y, button: keyName })
            SoundBeep 800
        }
    }

    OnKeyDown(inputHook, keyName) {
        if !this.isTracking
            return

        ; Ignore the hotkey itself
        if (keyName == '!t' || keyName == 'Alt' || keyName == 'T')
            return

        this.events.Push({ type: 'KeyDown', key: keyName })
        SoundBeep 600
    }

    UpdateEditBox() {
        code := ''
        code .= "ReplayTestAbsolute() {" "`n"
        if (this.targetWinTitle != '') {
            code .= Format("    `; Kích hoạt cửa sổ: {}`n", this.targetWinTitle)
            code .= Format("    WinActivate('ahk_exe {}')`n    Sleep(500)`n", this.targetWinExe)
        }
        for event in this.events {
            if (event.type == 'MouseClick') {
                posX := event.x
                posY := event.y
                code .= Format("    ClickEventAndSleep({}, {}, '{}')`n", posX, posY, event.button)
            } else if (event.type == 'KeyDown') {
                code .= Format("    KeyEventAndSleep('{}')`n", event.key)
            }
        }
        code .= "}`n`n"

        code .= "ReplayTestRelative() {" "`n"
        if (this.targetWinTitle != '') {
            code .= Format("    `; Kích hoạt cửa sổ: {}`n", this.targetWinTitle)
            code .= Format("    WinActivate('ahk_exe {}')`n    Sleep(500)`n", this.targetWinExe)
            code .= '    windowX := ' this.targetWinPos.x '`n'
            code .= '    windowY := ' this.targetWinPos.y '`n'
        }
        for event in this.events {
            if (event.type == 'MouseClick') {
                relX := event.x - this.targetWinPos.x
                relY := event.y - this.targetWinPos.y
                code .= Format("    ClickEventAndSleep({}, {}, '{}')`n", relX, relY, event.button)
            } else if (event.type == 'KeyDown') {
                code .= Format("    KeyEventAndSleep('{}')`n", event.key)
            }
        }
        code .= "}`n`n"

        code .= "ClickEventAndSleep(x, y, button, delay := 200) {" "`n"
        code .= "    Click(x, y, button)" "`n"
        code .= "    Sleep(delay)" "`n"
        code .= "}" "`n`n"

        code .= "KeyEventAndSleep(key, delay := 200) {" "`n"
        code .= "    Send('{' . key . '}')" "`n"
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
        if (this.lastCode != '') {
            this.editBox.Value := this.lastCode
            TrayTip("Đã phục hồi", "Đã trở về code lúc kết thúc theo dõi.", 2)
        } else {
            MsgBox "Chưa có code để phục hồi! Vui lòng thực hiện theo dõi chuột/phím trước."
        }
    }

    ExportScript() {
        filePath := 'D:\Documents\AutoHotkey\test\test.ahk'
        header := "#Requires AutoHotkey v2.0.18+" "`n" "#SingleInstance Force" "`n" "Persistent()" "`n`n"
        FileDelete filePath
        FileAppend header, filePath
        FileAppend this.editBox.Value, filePath
        TrayTip("Xuất file thành công", "File đã được lưu: " filePath, 2)
    }

    RunTestAbsolute() {
        this.ReplayWithVisuals("Absolute")
    }

    RunTestRelative() {
        this.ReplayWithVisuals("Relative")
    }

    ReplayWithVisuals(mode) {
        if (this.events.Length = 0) {
            MsgBox "Chưa có sự kiện để chạy!"
            return
        }

        localWinX := this.targetWinPos.x
        localWinY := this.targetWinPos.y
        localWinW := this.targetWinPos.w
        localWinH := this.targetWinPos.h

        ; Set up the overlay GUI
        testGui := Gui("+AlwaysOnTop -Caption +ToolWindow +LastFound", "Test Overlay")
        testGui.BackColor := "White"
        WinSetTransparent(150)

        if (mode == "Relative") {
            CoordMode 'Mouse', 'Window'
            if !this.targetWinID {
                MsgBox "Không có thông tin cửa sổ để chạy chế độ tương đối!"
                testGui.Destroy()
                return
            }
            WinActivate(this.targetWinID)
            testGui.Show("x" localWinX " y" localWinY " w" localWinW " h" localWinH)
        } else {
            CoordMode 'Mouse', 'Screen'
            testGui.Show("x0 y0 w" A_ScreenWidth " h" A_ScreenHeight)
        }

        for event in this.events {
            tooltipText := ''
            if (event.type == 'MouseClick') {
                x := (mode == 'Relative') ? event.x - localWinX : event.x
                y := (mode == 'Relative') ? event.y - localWinY : event.y
                this.DrawRedX(testGui, x, y)
                Click(x, y, event.button)
                tooltipText := Format('Đã click: {} tại ({}, {})', event.button, x, y)
            } else if (event.type == 'KeyDown') {
                Send('{' . event.key . '}')
                tooltipText := Format('Đã nhấn phím: {}', event.key)
            }
            ToolTip(tooltipText, A_ScreenWidth / 2 - 150, 0)
            Sleep(500)
        }

        Sleep(1000)
        ToolTip()
        testGui.Destroy()
        CoordMode 'Mouse', 'Screen'
    }

    DrawRedX(gui, x, y) {
        gui.SetFont("s10 bold", "Arial")
        gui.Add("Text", "x" (x - 3) " y" (y - 3) " w" 6 " h" 6 " vClickMarker BackgroundRed", "X")
    }
}
