global toggle := false
global currentKey := ""
global isScriptEnabled := false
global isOverlayVisible := false
global toggleF := []
loop 25
    toggleF.Push(false)

; ====== Hàm hiển thị và ẩn overlay =======
ShowStatusOverlay(isOn) {
    global statusOverlayGui

    if IsSet(statusOverlayGui)
        statusOverlayGui.Destroy()

    statusOverlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
    statusOverlayGui.BackColor := isOn ? "Green" : "Red"
    statusOverlayGui.SetFont("s10 Bold cWhite", "Segoe UI Emoji")

    guiWidth := 15
    guiHeight := 18
    statusOverlayGui.Add("Text", "Center w" guiWidth " h" guiHeight " BackgroundTrans", isOn ? "✅" : "⛔")

    screenHeight := A_ScreenHeight
    yPos := 0  ; top of screen

    statusOverlayGui.Show("x0 y" yPos " NoActivate")
}

HideStatusOverlay() {
    global statusOverlayGui
    if IsSet(statusOverlayGui)
        statusOverlayGui.Destroy()
}

; ======= Hàm chuyển đổi phím và gửi tự động =======
FormatSendKeys(keySpec) {
    mods := ""
    keys := ""

    ; Danh sách các phím đặc biệt
    specialKeys := Map(
        "enter", 1, "tab", 1, "esc", 1, "escape", 1, "space", 1,
        "backspace", 1, "delete", 1, "insert", 1, "home", 1, "end", 1,
        "pgup", 1, "pgdn", 1, "up", 1, "down", 1, "left", 1, "right", 1
    )
    ; Thêm các phím F1 đến F24 vào Map
    Loop 24 {
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
        ; Không có dấu + → tách modifier ra (nếu có)
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
        if specialKeys.Has(keyLower) || RegExMatch(keyLower, "^f\d{1,2}$")  ; hỗ trợ f1-f24 kể cả chưa trong map
            keys := FormatKey(keyLower)
        else if (StrLen(keyPart) = 1)
            keys := keyPart
        else
            keys := FormatKey(keyPart)
    }

    return mods . keys
}

AutoSendKey() {
    global currentKey
    Send(currentKey)
}

ToggleAndSend(idx, key1, key2) {
    global toggleF
    value := toggleF[idx]
    value := !value
    toggleF.RemoveAt(idx)
    toggleF.InsertAt(idx, value)
    Send(toggleF[idx] ? key1 : key2)
    SetTimer(HideToolTip, -1000)
}

ToggleAndExcute(idx, func1, func2) {
    global toggleF
    value := toggleF[idx]
    value := !value
    toggleF.RemoveAt(idx)
    toggleF.InsertAt(idx, value)
    
    if (toggleF[idx]) {
        func1()
    } else {
        func2()
    }
    
    SetTimer(HideToolTip, -1000)
}

HideToolTip(*) {
    ToolTip()
}