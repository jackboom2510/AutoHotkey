CoordMode "Mouse", "Screen"
class ClickTracker {
    static clicks := []
    static isTracking := false
    static gui := ""
    static lastCode := ""
    static editBox := ""
    static btnStart := ""
    static btnStop := ""
    static btnCopy := ""
    static btnDefault := ""
    static btnExport := ""
    static btnTest1 := ""
    static btnTest2 := ""
    static targetWinTitle := ""
    static targetWinID := 0
    static targetWinExe := ""
    static targetWinPos := { x: 0, y: 0, w: 0, h: 0 }

    static Init() {
        this.gui := Gui("+AlwaysOnTop -Resize", "Mouse Click Tracker")
        this.gui.BackColor := "E0FFFF"
        this.gui.SetFont("s12", "Segoe UI")

        this.btnStart := this.gui.Add("Button", "x15 y5 w150", "Bắt đầu")
        this.btnStop := this.gui.Add("Button", "x+5 w150 Hidden", "Kết thúc")
        this.btnTest1 := this.gui.Add("Button", "x+5 w100", "Test 1")
        this.btnDefault := this.gui.Add("Button", "xm y+10 w100", "Default")
        this.btnCopy := this.gui.Add("Button", "x+3 yp w100", "Copy")
        this.btnExport := this.gui.Add("Button", "x+3 w100", "Export")
        this.btnTest2 := this.gui.Add("Button", "x+5 w100", "Test 2")

        this.editBox := this.gui.Add("Edit", "xm y+10 w400 r12 -Wrap")  ; tăng chiều rộng editBox

        this.btnStart.OnEvent("Click", (*) => this.StartTracking())
        this.btnStop.OnEvent("Click", (*) => this.StopTracking())
        this.btnCopy.OnEvent("Click", (*) => this.CopyCode())
        this.btnExport.OnEvent("Click", (*) => this.ExportToFile())
        this.btnTest1.OnEvent("Click", (*) => this.RunTestAbsolute())
        this.btnTest2.OnEvent("Click", (*) => this.RunTestRelative())
        this.btnDefault.OnEvent("Click", (*) => this.RestoreDefault())

        this.gui.Show("AutoSize")
    }
        
    static Toggle()
    {
        if !this.gui
        {
            this.Init()
            return
        }

        hwnd := this.gui.Hwnd

        ; Kiểm tra cửa sổ có tồn tại hay không
        if !WinExist("ahk_id " hwnd)
        {
            this.gui.Show("AutoSize")
            return
        }

        winState := WinGetMinMax("ahk_id " hwnd)  ; -1: hidden, 0: normal, 1: maximized

        if winState = -1
            this.gui.Show("AutoSize")
        else
            this.gui.Hide()
    }

    static StartTracking() {
        this.clicks := []
        this.isTracking := true
        this.targetWinTitle := ""
        this.targetWinID := 0
        this.targetWinPos := { x: 0, y: 0, w: 0, h: 0 }
        this.btnStart.Visible := false
        this.btnStop.Visible := true
        this.gui.Minimize()
    }

    static StopTracking() {
        this.isTracking := false
        this.btnStart.Visible := true
        this.btnStop.Visible := false
        this.UpdateEditBox()
        TrayTip("Đã dừng", "Quá trình theo dõi đã kết thúc.", 2)
        this.gui.Show()
        WinActivate(this.gui.Hwnd)
    }

    static OnMouseClick() {
        if !this.isTracking
            return

        MouseGetPos &x, &y, &winHwnd

        if this.clicks.Length = 0 {
            title := WinGetTitle(Format("ahk_id {}", winHwnd))
            wx := wy := ww := wh := 0
            WinGetPos(&wx, &wy, &ww, &wh, Format("ahk_id {}", winHwnd))

            this.targetWinExe := WinGetProcessName(Format("ahk_id {}", winHwnd))
            this.targetWinTitle := title
            this.targetWinID := winHwnd
            this.targetWinPos := { x: wx, y: wy, w: ww, h: wh }
        }

        this.clicks.Push({ x: x, y: y })
        SoundBeep 800
    }

    static UpdateEditBox() {
        code := ""

        ; Hàm replay theo Test 1 (toạ độ tuyệt đối màn hình)
        code .= "ReplayTest1() {" "`n"
        if (this.targetWinTitle != "") {
            code .= Format('    WinActivate("ahk_exe {}")`n    Sleep(500)`n', this.targetWinExe)
            code .= '    screenW := ' A_ScreenWidth '`n    screenH := ' A_ScreenHeight '`n'
        }
        for pt in this.clicks {
            posX := pt.x + this.targetWinPos.x  ; giả sử toạ độ lưu là tương đối cửa sổ, nên cộng cửa sổ
            posY := pt.y + this.targetWinPos.y
            code .= Format("    ClickAndSleep({}, {})`n", posX, posY)
        }
        code .= "}`n`n"

        ; Hàm replay theo Test 2 (toạ độ tương đối cửa sổ)
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
            posX := pt.x  ; toạ độ tương đối cửa sổ
            posY := pt.y
            code .= Format("    ClickAndSleep({}, {})`n", posX, posY)
        }
        code .= "}`n`n"

        ; Hàm ClickAndSleep dùng chung
        code .= "ClickAndSleep(x, y, delay := 200) {" "`n"
        code .= "    Click(x, y)" "`n"
        code .= "    Sleep(delay)" "`n"
        code .= "}"

        this.editBox.Value := code
        this.lastCode := code
    }

    static CopyCode() {
        A_Clipboard := this.editBox.Value
        TrayTip("Đã sao chép!", "Mã mô phỏng đã được copy vào clipboard.", 1)
    }

    static RestoreDefault() {
        if (ClickTracker.lastCode != "") {
            ClickTracker.editBox.Value := ClickTracker.lastCode
            TrayTip("Đã phục hồi", "Đã trở về code lúc kết thúc theo dõi.", 2)
        } else {
            MsgBox "Chưa có code để phục hồi! Vui lòng thực hiện theo dõi chuột trước."
        }
    }

    static ExportToFile() {
        filePath := "C:\Users\jackb\Documents\AutoHotkey\test\test.ahk"
        header := "#Requires AutoHotkey v2.0.18+" "`n" "#SingleInstance Force" "`n" "Persistent()" "`n`n"
        FileDelete filePath  ; xóa nếu file đã tồn tại
        FileAppend header, filePath  ; ghi header 3 dòng đầu
        FileAppend ClickTracker.editBox.Value, filePath
        TrayTip("Xuất file thành công", "File đã được lưu: " filePath, 2)
    }

    static RunTestAbsolute() {
        ; Test theo toàn màn hình - overlay 1600x960 hoặc full màn hình
        screenWidth := A_ScreenWidth
        screenHeight := A_ScreenWidth

        testGui := Gui("-Caption +AlwaysOnTop +ToolWindow +LastFound", "Test Overlay")
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

    static RunTestRelative() {
        ; Test theo cửa sổ ban đầu - overlay nằm đúng vị trí cửa sổ đó
        win := this.targetWinID
        if !win {
            MsgBox "Chưa có thông tin cửa sổ!"
            return
        }

        x := this.targetWinPos.x, y := this.targetWinPos.y
        w := this.targetWinPos.w, h := this.targetWinPos.h

        testGui := Gui("-Caption +AlwaysOnTop +ToolWindow +LastFound", "Test Overlay (Window Based)")
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

    static DrawRedX(gui, x, y) {
        color := "Red"
        size := 3
        for offset in this.Range(-size, size)
            this.DrawSquare(gui, x + offset, y + offset, 2, color)
        for offset in this.Range(-size, size)
            this.DrawSquare(gui, x + offset, y - offset, 2, color)
        ; Thêm text hiển thị tọa độ ngay bên phải dấu X
        textX := x + size + 5  ; cách dấu X 5px theo chiều ngang
        textY := y - 7         ; canh cho text nằm gần dấu X

        gui.Add("Text", Format("x{} y{} w100 h15", textX, textY), Format("({}, {})", x, y))
    }

    static DrawSquare(gui, cx, cy, halfSize, color) {
        for dx in this.Range(-halfSize, halfSize) {
            for dy in this.Range(-halfSize, halfSize) {
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