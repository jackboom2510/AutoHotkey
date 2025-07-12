#Requires AutoHotkey v2.0+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent

ui()  ; Khởi tạo object trước

OnMessage(0x4E, ObjBindMethod(ui, "WM_NOTIFY"))  ; Đăng ký callback sau khi object đã có

class ui {
    static gui := unset
    static trans := 180
    static step := 10
    static min := 50
    static max := 255
    static edit := unset
    static updown := unset

    __New() {
        ui.gui := Gui("+AlwaysOnTop +Resize -DPIScale", "UI")
        ui.gui.SetFont("s10", "Verdana")

        ui.gui.AddButton(, "Select")
        ui.edit := ui.gui.AddEdit("w100")
        ui.updown := ui.gui.AddUpDown("-2 Range" ui.min "-" ui.max, ui.trans)

        ui.edit.Value := ui.trans
        ui.Show()
        ui.SetTrans()
    }

    static SetTrans(*) {
        WinSetTransparent(ui.trans, "UI")
    }

    static Show(*) {
        ui.gui.Show("x1200 y100 AutoSize")
    }

    static WM_NOTIFY(wParam, lParam, Msg, hWnd) {
        static UDN_DELTAPOS := -722
        static is64Bit := (A_PtrSize = 8)

        NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
        DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

        hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
        code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
        pos := NumGet(NMUPDOWN, is64Bit ? 20 : 12, "Int")
        delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

        if (hwndFrom = ui.updown.hwnd && code = UDN_DELTAPOS) {
            newVal := ui.updown.Value + delta * ui.step
            newVal := Min(Max(newVal, ui.min), ui.max)

            ui.updown.Value := newVal
            ui.edit.Value := newVal

            return true
        }
    }
}