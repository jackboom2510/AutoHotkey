global currentKey := ""
global currentProjectMode := false
global toggleASend := false
global toggleF := []
loop 25
    toggleF.Push(false)

class KeyBindingUI {
    _gui := unset
    guiID := ""
    name := "Key Binding Options Menu"
    guiOpts := "+AlwaysOnTop +Resize -DPIScale "
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
        this._gui := Gui(this.guiOpts, this.name)
        this.guiID := this._gui.hwnd
        this._gui.SetFont("s10", "Verdana")
        this._gui.BackColor := "E0FFFF"

        this.SetupAll(Addition*)
        this.Show()
        WinSetTransColor(this._gui.BackColor, this.name)
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
                    this.AdditionCtr.Push(this._gui.Add(ctrl[1], ctrl[3], ctrl[2]))
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
            ; Add Checkboxes for selecting actions
            this.tittle := this._gui.AddText("x100 w100 h22", "Options")
            this.tittle.SetFont("s12 Bold c6200ff", "Verdana")
            this.Checkbox[1] := this._gui.AddCheckbox("xm", "Utilities")
            this.Checkbox[1].Value := 1
            this.Checkbox[2] := this._gui.AddCheckbox("xm", "Disable PgUp && PgDown")
            this.Checkbox[2].Value := 1
            this.Checkbox[3] := this._gui.AddCheckbox("", "VSCode debug tasks")
            this.Checkbox[3].Value := 0
            this.Checkbox[4] := this._gui.AddCheckbox("", "Device configurations && MouseClick")
            this.Checkbox[4].Value := 0
            this._gui.AddEdit("xm w75 +Right").ToolTip := "Adjust " this.name "'s transparency (" this.transparencyMin "–" this
            .transparencyMax ")."
            this.transparencyUpDown := this._gui.AddUpDown("Range" this.transparencyMin "-" this.transparencyMax,
                this.transparency)
            this.ApplyBtn := this._gui.AddButton("xp+160 yp-2", "Apply && Exit")

        }

        SetupEvents() {
            ; Event handling for checkboxes selection
            this.ApplyBtn.OnEvent("Click", (*) => this._gui.Hide())
            ; this.Checkbox[1].OnEvent("Click", (*) => this.OnSelectAll)
            ; this.Checkbox[2].OnEvent("Click", (*) => this.OnSelectCommonFunction)
            ; this.Checkbox[3].OnEvent("Click") (*) => this.OnSelectDeviceConfig)
            ; this.Checkbox[4].OnEvent("Click") (*) => this.OnSelectVscodeDebug)
        }

        SetupToolTips() {
            this._gui.ToolTip := "Select checkboxes and press Apply."
            this.Checkbox[1].ToolTip := "Hotkeys for Utilities (Timer, ChangeProjectMode)"
            this.Checkbox[2].ToolTip := "Diasble/Enable PageUp && PageDown"
            this.Checkbox[3].ToolTip := "Hotkeys for VSCode debugging tasks"
            this.Checkbox[4].ToolTip := "Hotkeys for device configurations && Mouse Manipulation"
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
        this._gui.Show(ShowOtp)
        this.Checkbox[3].Focus()
    }
    Hide() {
        this._gui.Hide()
    }
    Toggle(*) {
        if WinExist('ahk_id ' this._gui.hwnd)
            this._gui.Hide()
        else {
            this._gui.Show()
            this.Checkbox[3].Focus()
        }
        return
    }

    OnSelectAll() {
        this.Checkbox[2].Value := !this.Checkbox[2].Value
        this.Checkbox[3].Value := !this.Checkbox[3].Value
        this.Checkbox[4].Value := !this.Checkbox[4].Value
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

ToggleAndSend(idx, key1, key2) {
    global toggleF
    value := toggleF[idx]
    value := !value
    toggleF.RemoveAt(idx)
    toggleF.InsertAt(idx, value)
    Send(toggleF[idx] ? key1 : key2)
    SetTimer(ToolTip, -1000)
}

ToggleAndExecute(idx, func1, func2, args1, args2) {
    global toggleF
    value := toggleF[idx]
    value := !value
    toggleF.RemoveAt(idx)
    toggleF.InsertAt(idx, value)

    if (toggleF[idx]) {
        if (Type(func1) = "String") {
            func1 := %func1%
        }
        try func1(args1*)
        catch as Err {
            MsgBox A_ScriptFullPath "`n`n❌ Error calling function: `"" func1.Name "`"`n" Type(Err) ": " Err.Message
            FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
            "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
        }
    } else {
        if (Type(func2) = "String") {
            func2 := %func2%
        }
        try func2(args2*)
        catch as Err {
            MsgBox A_ScriptFullPath "`n`n❌ Error calling function: `"" func2.Name "`"`n" Type(Err) ": " Err.Message
            FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
            "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
        }
    }

    SetTimer(ToolTip, -1000)
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

ToggleProjectMode() {
    displaySwitchPath := A_WinDir . "\System32\DisplaySwitch.exe"
    global currentProjectMode := !currentProjectMode

    if (currentProjectMode = 0) {
        Run displaySwitchPath " /extend"
        TrayTip "Project Mode", "Switched to: Extend (Desktop duplicated and extended to second screen)"
        OutputDebug "Switched to: Extend Mode"
    } else {
        Run displaySwitchPath " /external"
        TrayTip "Project Mode", "Switched to: Second screen only (Only the external display is active)"
        OutputDebug "Switched to: Second Screen Only Mode"
    }
}
