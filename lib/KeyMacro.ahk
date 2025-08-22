global currentKey := ""
global toggleASend := false
global cycleIdx := Map()

class KeyBindingUI {
    ui := unset
    guiID := ""
    name := "Key Binding Options Menu"
    guiOpts := "+AlwaysOnTop"
    xpos := 0
    ypos := 0
    guiWidth := 0
    guiHeight := 0
    transparency := 225
    transparencyMin := 120
    transparencyMax := 255
    transparencyStep := 15

    transparencyEdit := ""
    transparencyUpDown := ""

    Checkbox := ["", "", "", ""]
    ApplyBtn := ""
    AdditionCtr := []

    __New(Addition*) {
        if (this.guiID) {
            if (WinExist(this.name " ahk_id " this.guiID))
                return
        }
        this.ui := Gui(this.guiOpts, this.name)
        this.guiID := this.ui.hwnd
        this.ui.SetFont("s10", "Verdana")
        this.ui.BackColor := "E0FFFF"

        this.SetupAll(Addition*)
        this.Show()
        WinSetTransColor(this.ui.BackColor, this.name)
        WinSetTransparent(this.transparency, this.name)
        OnMessage(0x0200, ObjBindMethod(this, "On_WM_MOUSEMOVE"))
        OnMessage(0x004E, ObjBindMethod(this, "On_WM_NOTIFY"))
        ; OnMessage(0x0100, ObjBindMethod(this, "On_WM_KEYDOWN"))
    }

    SetUpAll(Addition*) {
        SetupControls
        SetupEvents
        SetupToolTips
        if (Addition.Length != 0) {
            for idx, ctrl in Addition {
                if (ctrl.has(1) && ctrl.has(2) && ctrl.has(3)) {
                    this.AdditionCtr.Push(this.ui.Add(ctrl[1], ctrl[3], ctrl[2]))
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
                    this.AdditionCtr[idx].OnEvent("Click", ctrl[4])
                if (ctrl.has(5))
                    this.AdditionCtr[idx].ToolTip := ctrl[5]
            }
        }
        return
        SetupControls() {
            this.tittle := this.ui.AddText("x100 w100 h22", "Options")
            this.tittle.SetFont("s12 Bold c6200ff", "Verdana")
            this.Checkbox[1] := this.ui.AddCheckbox("xm", "Utilities")
            this.Checkbox[1].Value := 1
            this.Checkbox[2] := this.ui.AddCheckbox("xm", "Disable PgUp && PgDown")
            this.Checkbox[2].Value := 1
            this.Checkbox[3] := this.ui.AddCheckbox("xm", "Alternative MoveKey")
            this.Checkbox[3].Value := 1
            this.Checkbox[4] := this.ui.AddCheckbox("xm", "The King Is Watching")
            this.Checkbox[4].Value := 0
            this.ui.AddEdit("xm w75 +Right").ToolTip := "Adjust " this.name "'s transparency (" this.transparencyMin "–" this
            .transparencyMax ")."
            this.transparencyUpDown := this.ui.AddUpDown("Range" this.transparencyMin "-" this.transparencyMax,
                this.transparency)
            this.ApplyBtn := this.ui.AddButton("xp+160 yp-2", "Apply && Exit")

        }

        SetupEvents() {
            this.ApplyBtn.OnEvent("Click", (*) => this.ui.Hide())
        }

        SetupToolTips() {
            this.ui.ToolTip := "Select checkboxes and press Apply."
            this.Checkbox[1].ToolTip := "Hotkeys for Utilities (Timer, ChangeProjectMode)"
            this.Checkbox[2].ToolTip := "Diasble/Enable PageUp && PageDown"
            this.Checkbox[3].ToolTip := "Use Alt + wasd <-> Arrows Keys"
        }
    }

    Show(xpos := this.xpos, ypos := this.ypos, guiWidth := this.guiWidth, guiHeight := this.guiHeight, option*) {
        ; xpos := (xpos = 0) ? "Center" : xpos
        ; ypos := (ypos = 0) ? "Center" : ypos
        ; if (guiWidth = 0 || guiWidth = 0) {
        ;     if()
        ;     _UI.gui.Show("x" xpos " y" ypos " Restore")
        ; } else {
        ;     _UI.gui.Show("x" xpos " y" ypos " w" guiWidth " h" guiHeight " Restore" option*)
        ; }
        ShowOtp := ""
        if (this.xpos != 0)
            ShowOtp .= Format("x{} ", this.xpos)
        if (this.ypos != 0)
            ShowOtp .= Format("y{} ", this.ypos)
        this.ui.Show(ShowOtp)
    }
    Hide() {
        this.ui.Hide()
    }
    Toggle(*) {
        if WinExist('ahk_id ' this.ui.hwnd)
            this.ui.Hide()
        else {
            this.ui.Show()
        }
        return
    }

    On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
        PrevHwnd := 0
        if (Hwnd != PrevHwnd) {
            Text := ""
            SetTimer(ToolTip)
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
    On_WM_NOTIFY(wParam, lParam, Msg, hWnd) {
        UDN_DELTAPOS := -722
        is64Bit := (A_PtrSize = 8)

        NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
        DllCall("RtlMoveMemory", "Ptr", NMUPDOWN.Ptr, "Ptr", lParam, "UPtr", NMUPDOWN.Size)

        hwndFrom := NumGet(NMUPDOWN, 0, "UPtr")
        code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, "Int")
        delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, "Int")

        if (hwndFrom = this.transparencyUpDown.hwnd && code = UDN_DELTAPOS) {
            newVal := this.transparencyUpDown.Value + delta * this.transparencyStep
            newVal := Min(Max(newVal, this.transparencyMin), this.transparencyMax)
            this.transparencyUpDown.Value := newVal
            this.transparency := newVal
            WinSetTransparent this.transparency, this.name
            return true
        }
    }
    On_WM_KEYDOWN(wParam, lParam, msg, Hwnd) {
        if (wParam >= 0x31 && wParam <= 0x34) {
            idx := wParam - 0x31 + 1
            this.Checkbox[idx].value := !this.Checkbox[idx].value
            return true
        }
        return false
    }
}

FormatSendKeys(keySpec) {
    mods := ""
    keys := ""

    specialKeys := Map(
        "enter", 1, "tab", 1, "esc", 1, "escape", 1, "space", 1,
        "backspace", 1, "delete", 1, "insert", 1, "home", 1, "end", 1,
        "pgup", 1, "pgdn", 1, "up", 1, "down", 1, "left", 1, "right", 1
    )

    loop 24 {
        key := "f" . A_Index
        specialKeys[key] := 1
    }

    FormatKey(key) {
        return "{" . key . "}"
    }

    keySpec := StrReplace(keySpec, " ", "")

    if InStr(keySpec, "+") {
        parts := StrSplit(keySpec, "+")
        for part in parts {
            partLower := StrLower(part)
            switch partLower {
                case "ctrl":
                    mods .= "^"
                case "alt":
                    mods .= "!"
                case "shift":
                    mods .= "+"
                case "win":
                    mods .= "#"
                default:
                    if specialKeys.Has(partLower)
                        keys .= FormatKey(partLower)
                    else if (StrLen(part) = 1)
                        keys .= part
                    else
                        keys .= FormatKey(part)
            }
        }
    } else {

        i := 1
        while i <= StrLen(keySpec) {
            c := SubStr(keySpec, i, 1)
            if (c = "!" || c = "^" || c = "+" || c = "#") {
                mods .= c
                i++
            } else {
                break
            }
        }

        keyPart := SubStr(keySpec, i)
        keyLower := StrLower(keyPart)
        if specialKeys.Has(keyLower) || RegExMatch(keyLower, "^f\d{1,2}$")
            keys := FormatKey(keyLower)
        else if (StrLen(keyPart) = 1)
            keys := keyPart
        else
            keys := FormatKey(keyPart)
    }

    return mods . keys
}

RunFunctions(args*) {
    if (args.Length = 1) {
        if ((args[1].Length = 1))
            return RunFunction(args[1][1])
        if (!IsObject(args[1][2]))
            return RunFunction(args[1][1], args[1][2])
        return RunFunction(args[1][1], args[1][2]*)
    }
    for idx, fn in args {
        if ((fn.Length = 1)) {
            RunFunction(fn[1])
            continue
        }
        if (!IsObject(fn[2]))
            return RunFunction(fn[1], fn[2])
        RunFunction(fn[1], fn[2]*)
    }
    return
    RunFunction(fn, args*) {
        if (Type(fn) = "String")
            fn := %fn%
        if (args.Length = 0) {
            fn()
            return
        }
        fn(args*)
        return
    }
}

CycleAndSend(idx, sends) {
    global cycleIdx
    if !cycleIdx.Has(idx)
        cycleIdx[idx] := 1
    else {
        cycleIdx[idx]++
        if (cycleIdx[idx] > sends.Length)
            cycleIdx[idx] := 1
    }

    current := sends[cycleIdx[idx]]

    try {
        Send current
    } catch as Err {
        MsgBox A_ScriptFullPath "`n`n❌ Error sending: " current "`n" Type(Err) ": " Err.Message
        FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
        "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
    }

    SetTimer(ToolTip, -1000)
}

CycleAndExecute(idx, funcsAndArgs) {
    global cycleIdx
    if !cycleIdx.Has(idx)
        cycleIdx[idx] := 1
    else {
        cycleIdx[idx]++
        if (cycleIdx[idx] > funcsAndArgs.Length)
            cycleIdx[idx] := 1
    }

    current := funcsAndArgs[cycleIdx[idx]]
    func := current[1]
    args := current.Length > 1 ? current[2] : []

    try {
        if (Type(func) = "String") {
            fn := %func%
            fn(args*)
        } else {
            func(args*)
        }
    } catch as Err {
        MsgBox A_ScriptFullPath "`n`n❌ Error calling function: " Type(func) "`n" Type(Err) ": " Err.Message
        FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
        "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
    }

    SetTimer(ToolTip, -1000)
}

DynamicSet(varName, value) {
    global
    %varName% := value
}

InputBoxForAutoSendToggle() {
    global toggleASend, currentKey
    toggleASend := !toggleASend
    if toggleASend {
        result := InputBox("Nhập phím bạn muốn gửi liên tục:", "Nhập phím", "w300 h150")
        if result.Result != "OK" || result.Value = "" {
            toggleASend := false
            return
        }
        currentKey := FormatSendKeys(result.Value)
        ToolTip("Gửi tự động phím: " . currentKey)
        SetTimer(Send(currentKey), 1000)
    } else {
        ToolTip("Dừng gửi phím: " . currentKey)
        SetTimer(Send(currentKey), 0)
    }
    SetTimer(ToolTip, -1500)
}
