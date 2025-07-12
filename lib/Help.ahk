#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <Log>

OnMessage(0x0200, ObjBindMethod(UI, "On_WM_MOUSEMOVE"))
OnMessage(0x4E, ObjBindMethod(UI, "WM_NOTIFY"))

UI
class UI {
    static gui := unset
    static name := "UI"

    static xpos := 0
    static ypos := 0
    static guiWidth := 0
    static guiHeigth := 0

    static transparency := 255
    static transparencyMin := 30
    static transparencyMax := 255
    static transparencyStep := 15

    static transparencyEdit := ""
    static transparencyUpDown := ""

    static scriptsDdl := ""
    static scripts := []
    
    __New() {
        UI.gui := Gui("+AlwaysOnTop +Resize -DPIScale", UI.name)
        UI.gui.SetFont("s10", "Verdana")
        UI.gui.BackColor := "E0FFFF"

        UI.SetupAll()

        UI.Show()
        WinSetTransColor(UI.gui.BackColor, UI.name)
        WinSetTransparent(UI.transparency, UI.name)
    }
    static SetUpAll() {
        SetupControls() {
            UI.scriptsDdl := UI.gui.AddDropDownList("w300", UI.scripts)
            UI.edithk := UI.gui.AddEdit(, "Edit Hotkeys")
            UI.btnRunScript := UI.gui.AddButton(, "Run Script")
            UI.btnEditScript := UI.gui.AddButton(, "Edit Script")
            UI.btnAdd := UI.gui.AddButton(, "Add")
            UI.btnDel := UI.gui.AddButton(, "Del")

            
            UI.gui.AddEdit("+Right").ToolTip := "Adjust " UI.name "'s transparency (" UI.transparencyMin "–" UI.transparencyMax ")."
            UI.transparencyUpDown := UI.gui.AddUpDown("Range" UI.transparencyMin "-" UI.transparencyMax,
                UI.transparency)
        }
        SetupEvents() {

        }
        SetupToolTips() {
        }
        SetupControls
        SetupEvents
        SetupToolTips
    }

    static Show(xpos := UI.xpos, ypos := UI.ypos, guiWidth := UI.guiWidth, guiHeight := UI.guiHeigth, option*) {
        xpos := (xpos = 0) ? "Center" : xpos
        ypos := (ypos = 0) ? "Center" : ypos
        if (guiWidth = 0 || guiWidth = 0) {
            UI.gui.Show("x" xpos " y" ypos " Restore")
        }
        else {
            UI.gui.Show("x" xpos " y" ypos " w" guiWidth " h" guiHeight " Restore" option*)
        }
    }

    static Toggle() {
        if !UI.gui {
            UI
            return
        }
        hwnd := UI.gui.Hwnd
        if !WinExist("ahk_id " hwnd) {
            UI.Show()
            return
        }
        winState := WinGetMinMax("ahk_id " hwnd)
        if winState = -1
            UI.gui.Show()
        else
            UI.gui.Hide()
    }

    static WM_NOTIFY(wParam, lParam, Msg, hWnd) {
        static UDN_DELTAPOS := -722
        static is64Bit := (A_PtrSize = 8)

        NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
        DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

        hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
        code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
        delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

        if (hwndFrom = UI.transparencyUpDown.hwnd && code = UDN_DELTAPOS) {
            newVal := UI.transparencyUpDown.Value + delta * UI.transparencyStep
            newVal := Min(Max(newVal, UI.transparencyMin), UI.transparencyMax)
            UI.transparencyUpDown.Value := newVal
            UI.transparency := newVal
            WinSetTransparent UI.transparency, UI.name
            return true
        }
    }

    static On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
        static PrevHwnd := 0
        if (Hwnd != PrevHwnd) {
            Text := "", ToolTip()
            CurrControl := GuiCtrlFromHwnd(Hwnd)
            if CurrControl {
                if !CurrControl.HasProp("ToolTip")
                    return
                Text := CurrControl.ToolTip
                ToolTip(Text)
            }
            PrevHwnd := Hwnd
        }
    }
}

FileObj.Close()