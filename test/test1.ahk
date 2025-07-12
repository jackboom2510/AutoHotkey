#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <Log>

ui
class ui {
    static gui := unset
    static trans := 180
    __New() {
        ui.gui := Gui("+AlwaysOnTop +Resize -DPIScale", "UI")
        ui.gui.SetFont("s10", "Verdana")
        ui.gui.AddButton(, "Select")

        ui.myEdit := ui.gui.AddEdit()
        ui.myUpDown := ui.gui.AddUpDown("Range50-255", ui.trans)
        ui.Show()
        ui.SetUpDownStep(ui.myUpDown.hwnd, 10) ; Bước nhảy là 10
        ui.SetTrans()
    }
    static SetUpDownStep(hUpDown, step := 5) {
        static UDM_SETACCEL := 0x2008

        accel := Buffer(8, 0)  ; 8 bytes: UDACCEL struct

        NumPut("UInt", 0, accel, 0)    ; nSec (delay ms)
        NumPut("UInt", step, accel, 4) ; nInc (increment)

        SendMessage(UDM_SETACCEL, 1, accel.Ptr, , "ahk_id " hUpDown)
    }
    static SetTrans(*) {
        WinSetTransparent(ui.trans, "UI")
    }
    static Show(*) {
        ui.gui.Show("x1200 y100 AutoSize")
    }
}

FileObj.Close()