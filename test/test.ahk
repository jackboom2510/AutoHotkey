#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

; #Include <Log>

_gui := Gui()
_gui.AddText(, "RandomText")
AdditionCtr := Array()
passarg(["Button", "Hotkeys", "", (*) => MsgBox(), "Show Hotkeys"])

passarg(Addition*) {
    if (Addition.Length != 0) {
        for idx, ctrl in Addition {
            if (ctrl.has(1) && ctrl.has(2) && ctrl.has(3)) {
                AdditionCtr.Push(_gui.Add(ctrl[1], ctrl[3], ctrl[2]))
            }
            else {
                debugStr := "Missing some parameters:`n"
                if (!ctrl.has(1))
                    debugStr .= "- ControlType`n"
                if (!ctrl.has(3))
                    debugStr .= "- Text`n"
                if (!ctrl.has(2))
                    debugStr .= "- Options"
                TrayTip(debugStr, "Error!", 3)
                OutputDebug(debugStr)
            }
            if (ctrl.has(4))
                AdditionCtr[idx].OnEvent("Click", ctrl[4])
            if (ctrl.has(5))
                AdditionCtr[idx].ToolTip := ctrl[5]
        }
    }
}
_gui.Show()