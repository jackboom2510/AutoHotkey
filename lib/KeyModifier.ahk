global currentKey := ""
global toggle := false
global toggleF := []
loop 25
    toggleF.Push(false)

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

ToggleAndExecute(idx, func1, func2) {
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

    SetTimer(ToolTip, -1000)
}

InputBoxForAutoSendToggle() {
    global toggle, currentKey
    toggle := !toggle
    if toggle {
        result := InputBox("Nhập phím bạn muốn gửi liên tục:", "Nhập phím", "w300 h150")
        if result.Result != "OK" || result.Value = "" {
            toggle := false
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