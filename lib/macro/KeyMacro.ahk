#Include <core\Core>
#Include <ui\StatusOverlay>
global currentKey := ""
global toggleASend := false
; Checkbox := [
;__New(flagCB := "", input_cb := [], args*)
;     ["Utilities", 1],
;     [""]
;     ["Alternative MoveKey", 1],
;     ["Alternative WheelKey"]
; ]
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
    lastToggleTime := []
    Checkbox := [
        [
            "Utilities",
            1
        ],
        [
            ""
        ],
        [
            "Alternative MoveKey",
            1
        ],
        [
            "Alternative WheelKey"
        ],
        [
            "Monitor Navigate"
        ],
        [
            "Flex Configure"
        ],
        [
            "Alter Click (Down)"
        ],
        [
            "Alternative Copy",
            1
        ]
    ]
    ApplyBtn := ""
    AdditionCtr := []
    __New(flagCB := "", input_cb := [], args*) {
        if (this.guiID) {
            if (WinExist(this.name " ahk_id " this.guiID))
                return
        }
        this.ui := Gui(this.guiOpts, this.name)
        this.guiID := this.ui.hwnd
        this.ui.SetFont("s10", "Verdana")
        this.ui.BackColor := "E0FFFF"
        this.SetupAll(flagCB, input_cb, args*)
        this.Show()
        try WinSetTransColor(this.ui.BackColor, this.name)
        try WinSetTransparent(this.transparency, this.name)
        ; OnMessage(0x0200, ObjBindMethod(this, "On_WM_MOUSEMOVE"))
        ; OnMessage(0x004E, ObjBindMethod(this, "On_WM_NOTIFY"))
        ; OnMessage(0x0100, ObjBindMethod(this, "On_WM_KEYDOWN"))
    }
    SetUpAll(flagCB := "", input_cb := [], args*) {
        if (flagCB = '' || flagCB = 'back') {
            for , ele in input_cb {
                this.Checkbox.Push(ele)
            }
        }
        else if (flagCB = 'front') {
            for , ele in this.Checkbox {
                input_cb.Push(ele)
            }
            this.Checkbox := input_cb
        }
        else if (flagCB = 'replace') {
            this.Checkbox := input_cb
        }
        MoreControls_Original(args*)
        SetupControls
        ; MoreControls(args*)
        SetupEvents
        return
        MoreControls_Original(args*) {
            if (args.Length != 0) {
                for idx, ctrl in args {
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
        }
        MoreControls(pos, args*) {
            for idx, ctrl in args {
                renderPos := ctrl.Has(6) ? ctrl[6] : "back"
                if (renderPos != pos)
                    continue

                if (ctrl.Has(1) && ctrl.Has(2) && ctrl.Has(3)) {
                    c := this.ui.Add(ctrl[1], ctrl[3], ctrl[2])
                    this.AdditionCtr.Push(c)
                } else {
                    TrayTip("Missing parameters", "Error")
                    continue
                }

                if (ctrl.Has(4))
                    c.OnEvent("Click", ctrl[4])
                if (ctrl.Has(5))
                    c.ToolTip := ctrl[5]
            }
        }
        SetupControls(args*) {
            this.title := this.ui.AddText("x100 w100 h22", "Options")
            this.title.SetFont("s12 Bold c6200ff", "Verdana")
            for idx, ele in this.Checkbox {
                this.lastToggleTime.Push(0)
                this.Checkbox[idx] := this.ui.AddCheckbox("xm", ele[1])
                this.Checkbox[idx].Value := (ele.has(2) ? ele[2] : 0)
                if (ele.has(3))
                    this.Checkbox[idx].ToolTip := ele[3]
            }
            this.ui.AddEdit("xm w75 +Right")
            .ToolTip := "Adjust " this.name "'s transparency (" this.transparencyMin "–" this
            .transparencyMax ")."
            this.transparencyUpDown := this.ui.AddUpDown("Range" this.transparencyMin "-" this.transparencyMax,
                this.transparency)
            this.ApplyBtn := this.ui.AddButton("xp+160 yp-2", "Apply && Exit")
        }
        SetupEvents() {
            this.ApplyBtn.OnEvent("Click", (*) => this.ui.Hide())
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
    ToggleCheckbox(id := 1, cooldown := 2000) {
        now := A_TickCount
        if now - this.lastToggleTime[id] < cooldown {
            SoundBeep
            return
        }
        this.lastToggleTime[id] := now
        this.Checkbox[id].Value := !this.Checkbox[id].Value
        Notify.Prototype.DefineProp("InitSetup", { Call: (this) => (this.defaultWidth := 300) })
        if this.Checkbox[id].Value
            Notify("On", this.Checkbox[id].Text || Format("Option[{}]", id), "+ t2 c73AF6F")
        else
            Notify("Off", this.Checkbox[id].Text || Format("Option[{}]", id), "+ t2 cE67E22")
    }
    Toggle() {
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
    }
    else {
        i := 1
        while i <= StrLen(keySpec) {
            c := SubStr(keySpec, i, 1)
            if (c = "!" || c = "^" || c = "+" || c = "#") {
                mods .= c
                i++
            }
            else {
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
    }
    else {
        ToolTip("Dừng gửi phím: " . currentKey)
        SetTimer(Send(currentKey), 0)
    }
    SetTimer(ToolTip, -1500)
}

; numKeyOverlay := StatusOverlay(
;     'NumKey Overlay',
;     Format('bg1{} tx1{} bg2{} tx2{} x{}',
;         "009688", "ffffff",
;         "9C27B0", "ffffff",
;         22,
;     ),
;     'p{OnIcon}🔢', 'p{OffIcon}🔟'
; )

; ToggleNumKeyOverlay() {
;     numKeyOverlay.ToggleScript()
;     SoundPlay("D:\Downloads\Music\computer-mouse-click-352734.mp3")
; }

; #HotIf numKeyOverlay.isScriptEnabled
; 1::Numpad1
; 2::Numpad2
; 3::Numpad3
; 4::Numpad4
; 5::Numpad5
; 6::Numpad6
; 7::Numpad7
; 8::Numpad8
; 9::Numpad9
; 0::Numpad0
; #HotIf
