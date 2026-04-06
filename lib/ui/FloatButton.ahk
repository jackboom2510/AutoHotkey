#Requires AutoHotkey v2.0
Persistent

global gdipToken := Buffer(8)  ; Nhận token 64-bit từ GDI+

; Khởi tạo GDI+
GdiplusStartupInput := Buffer(16, 0)
NumPut("UInt", 1, GdiplusStartupInput, 0)  ; GdiplusVersion = 1
DllCall("gdiplus\GdiplusStartup", "Ptr", gdipToken, "Ptr", GdiplusStartupInput, "Ptr", 0)

OnExit(ExitFunc)

class FloatButton {
    static instances := []
    gui := ""
    guiSize := 80
    x := 100
    y := 100
    bgColor := "0078D4"  ; Màu nền

    __New(x := 100, y := 100, size := 80) {
        this.x := x
        this.y := y
        this.guiSize := size
        this.Show()
        FloatButton.instances.Push(this)
    }

    Show() {
        if this.gui
            this.gui.Destroy()

        this.gui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        this.gui.BackColor := "FFFFFF"
        this.gui.SetFont("s10", "Segoe UI")

        hBitmap := this.DrawCircle(this.guiSize, this.bgColor)
        this.btn := this.gui.AddPicture("x0 y0 w" this.guiSize " h" this.guiSize, "HBITMAP:" hBitmap)

        this.btn.OnEvent("Click", (*) => MsgBox("Clicked float button!"))
        this.gui.Show("x" this.x " y" this.y " NoActivate")
    }

    DrawCircle(diameter, hexColor) {
        ; Convert HEX to ARGB
        a := 0xFF
        r := "0x" SubStr(hexColor, 1, 2)
        g := "0x" SubStr(hexColor, 3, 2)
        b := "0x" SubStr(hexColor, 5, 2)
        color := (a << 24) | (r << 16) | (g << 8) | b

        hBitmap := 0
        hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
        hbm := DllCall("CreateCompatibleBitmap", "Ptr", hdc, "Int", diameter, "Int", diameter, "Ptr")
        obm := DllCall("SelectObject", "Ptr", hdc, "Ptr", hbm, "Ptr")

        ; GDI+ Graphics
        pGraphics := 0
        DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &pGraphics)
        DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", pGraphics, "Int", 4)

        ; GDI+ Brush
        pBrush := 0
        DllCall("gdiplus\GdipCreateSolidFill", "UInt", color, "Ptr*", &pBrush)
        DllCall("gdiplus\GdipFillEllipse", "Ptr", pGraphics, "Ptr", pBrush, "Float", 0, "Float", 0, "Float", diameter,
            "Float", diameter)

        ; Cleanup
        DllCall("gdiplus\GdipDeleteBrush", "Ptr", pBrush)
        DllCall("gdiplus\GdipDeleteGraphics", "Ptr", pGraphics)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", obm)
        DllCall("DeleteDC", "Ptr", hdc)

        return hbm
    }
}

; Tạo FloatButton
btn := FloatButton(300, 300, 100)

ExitFunc(*) {
    DllCall("gdiplus\GdiplusShutdown", "Ptr", gdipToken)
    ExitApp()
}
