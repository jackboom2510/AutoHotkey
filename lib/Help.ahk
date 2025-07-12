#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <Log>

OnMessage(0x0200, On_WM_MOUSEMOVE)

On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
    static PrevHwnd := 0
    if (Hwnd != PrevHwnd) {
        Text := "", ToolTip()
        CurrControl := guiCtrlFromHwnd(Hwnd)
        if CurrControl {
            if !CurrControl.HasProp("ToolTip")
                return
            Text := CurrControl.ToolTip
            ToolTip(Text)
        }
        PrevHwnd := Hwnd
    }
}

HelpTool.scriptList := ["Script1", "Script2", "Script3"]
HelpTool

Class HelpTool {
	static hui := unset
	static scriptDdl := ""
	static scriptList := []
	static transparency := 225
	__New() {
		HelpTool.hui := Gui("+AlwaysOnTop +Resize -DPIScale", "HelpTool")
		HelpTool.hui.SetFont("s10", "Verdana")
		; hui.BackColor := "b4feff"

		HelpTool.SetupControls()
		HelpTool.SetupEvents()
		HelpTool.SetupToolTips()

		HelpTool.hui.Show()
		; WinSetTransColor(hui.BackColor, "HelpTool")
		; WinSetTransparent(Help.transparency, "HelpTool")
	}
	static SetupControls() {
		HelpTool.scriptDdl := HelpTool.hui.AddDropDownList("w200 Choose" HelpTool.scriptList.Length, HelpTool.scriptList)
		HelpTool.btnEdit := HelpTool.hui.AddButton("w50 h25 yp", "Edit")
		HelpTool.btnAdd := HelpTool.hui.AddButton("x10 y+5 w50 h25", "Add")
		HelpTool.btnDel := HelpTool.hui.AddButton("w50 h25 yp", "Del")
	}
	static SetupEvents() {

	}
	static SetupToolTips() {

	}
}


FileObj.Close()