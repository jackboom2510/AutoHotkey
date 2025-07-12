#Include <JSON>
hotkeysJSON := "C:\Users\jackb\Documents\AutoHotkey\configs\hotkeys.json"
hotkeys := JSON.LoadFile(hotkeysJSON)

BindingAll(citeria := "") {
    for script_id, script in hotkeys {
        BindingScript(script, citeria)
    }
}

BindingScript(script, citeria := "") {
    notification := ""
    for fn_id, fn in hotkeys[script] {
        if (fn.has("isMethod") && fn["isMethod"] = true) {
            fullFn := StrSplit(fn_id, '.')
            try {
                fn_id := ObjBindMethod(%fullFn[1]%, fullFn[2])
            }
            catch as Err {
                TrayTip "❌ Error running when running " fullFn[1] '.' fullFn[2] ': ' Err.Message
                FileOpen("C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt", 'a').Write(
                    "Error writing to file: " Err.Message "`n")
            }
        }
        if (fn.has("args")) {
            for args_id, args in fn["args"] {
                hk := fn["hotkeys"][args_id]
                if (IsObject(args)) {
                    if (IsObject(hk)) {
                        notification .= hk[1] "`t-> " fn_id "("  ")" "`n"
                        HotIf citeria
                        AssignHotkey(hk[1], fn_id, , , args*)
                        HotIf
                    }
                    else {
                        notification .= hk "`t-> " fn_id "`n"
                        AssignHotkey(hk, fn_id, , , args*)
                    }
                }
                else {
                    hk := fn["hotkeys"][args_id]
                    if (IsObject(hk)) {
                        notification .= hk[1] "`t-> " fn_id "`n"
                        HotIf citeria
                        AssignHotkey(hk[1], fn_id, , , args)
                        HotIf
                    }
                    else {
                        notification .= hk "`t-> " fn_id "`n"
                        AssignHotkey(hk, fn_id, , , args)
                    }
                }
            }
        }
        else {
            hk := fn["hotkeys"][1]
            if (IsObject(hk)) {
                notification .= hk[1] "`t-> " fn_id "`n"
                HotIf citeria
                AssignHotkey(hk[1], fn_id)
                HotIf
            }
            else {
                notification .= hk "`t-> " fn_id "`n"
                AssignHotkey(hk, fn_id)
            }
        }
    }
    MsgBox(notification)
    return hotkeys[script]
}

AssignHotkey(KeyName, Function, Options := "", Default := "!t", FnArgs*) {
    if (KeyName = "" || Trim(KeyName) = "") {
        KeyName := Default
    }

    if (KeyName = "" || Trim(KeyName) = "") {
        TrayTip "⚠️ Không thể gán hotkey vì không có KeyName hợp lệ."
        return false
    }

    if (Type(Function) = "String") {
        Function := %Function%
    }

    if !IsObject(Function) || !Function.HasMethod("Call") {
        TrayTip "❌ Callback không hợp lệ."
        return false
    }
    try Hotkey(KeyName, "Off")

    try {
        Hotkey(KeyName, (*) => Function.Call(FnArgs*), Options)
        return true
    } catch as e {
        TrayTip "❌ Lỗi khi gán hotkey `"" KeyName "`" cho `"" Function.Name "`": " e.Message
        return false
    }
}

FnCall(Function, args*) {
    if (Type(Function) = "String")
        Function := %Function%
    try Function.Call(args*)
    catch as Err {
        MsgBox A_ScriptFullPath "`n`n❌ Error calling function: `"" Function.Name "`"`n" Type(Err) ": " Err.Message
        FileAppend "❌ [" A_ScriptFullPath "]`n`t- " Type(Err) ": " Err.Message "`n",
        "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
    }
}

/**
 * ### Regular Expression:
 * - **Phím điều khiển**: 
 *   - `+` → Shift  
 *   - `^` → Ctrl  
 *   - `!` → Alt  
 *   - `#` → Windows  
 * 
 * - **Phím đơn**: Các ký tự phím như `a`, `b`, `1`, `F1` v.v. không cần dấu `{}`.
 * 
 * - **Các ký tự đặc biệt**:  
 *   - `{}` dùng để bao quanh phím điều khiển hoặc các ký tự đặc biệt.  
 *   - Ví dụ: `{+}`, `{^}`, `{!}`, `{#}` cho phép mô tả tổ hợp phím cụ thể.
 * 
 * @description  
 * Giải thích một biểu thức hotkey (tổ hợp phím tắt) và trả về chuỗi mô tả dễ hiểu.
 * Biểu thức hotkey có thể bao gồm các phím điều khiển như `Ctrl`, `Shift`, `Alt`, `Windows` 
 * và các phím đơn. Cũng có thể bao gồm các ký hiệu đặc biệt như `{}`, `{+}`, `{^}`, `{!}`, `{#}`, v.v.
 * 
 * @param {String} hotkey - Biểu thức hotkey cần giải thích.  
 *                          Các phím có thể là ký hiệu phím đặc biệt hoặc phím đơn như:
 *                          - `+` = Shift, `^` = Ctrl, `!` = Alt, `#` = Windows.
 *                          - Các phím đơn như `a`, `s`, `1`, `F1`, `Esc` v.v. có thể không cần thêm dấu ngoặc.
 *                          - Có thể bao gồm các ký tự đặc biệt như `{}` dùng để bao quanh phím điều khiển.
 * 
 * @returns {String} - Chuỗi mô tả các phím tắt dưới dạng dễ hiểu.  
 *                    Ví dụ: "Shift + Alt + S", "Ctrl + Shift + X", "Windows + F".
 *                    Nếu không có phím đặc biệt nào, sẽ chỉ trả về tên phím đơn.
 * 
 * @example  
 * 
 * @see {@link https://www.autohotkey.com/docs/v2/lib/Send.htm|Send()}  
 * @see {@link https://www.autohotkey.com/docs/v2/lib/SendMode.htm|SendMode()}  
 * @see {@link https://www.autohotkey.com/docs/v2/lib/SendInput.htm|SendInput()}
 * 
 * @remarks  
 * - Dấu `{}` dùng để bao quanh các phím điều khiển giúp biểu thức được gửi bằng mã phím ảo, 
 *   ngay cả khi ký tự không tồn tại trên bàn phím hiện tại.
 * - Biểu thức hotkey có thể bao gồm các ký hiệu đặc biệt như `{+}`, `{^}`, `{!}`, `{#}` để chỉ các phím modifier.
 * 
 */
HotkeyExp(hotkey) {
    local explanation := ""

    ; Kiểm tra phím Shift (+)
    if (InStr(hotkey, "+")) {
        explanation .= "Shift"
        hotkey := StrReplace(hotkey, "+")  ; Loại bỏ Shift
    }

    ; Kiểm tra phím Alt (!)
    if (InStr(hotkey, "!")) {
        if (explanation) {
            explanation .= " + "
        }
        explanation .= "Alt"
        hotkey := StrReplace(hotkey, "!")  ; Loại bỏ Alt
    }

    ; Kiểm tra phím Ctrl (^)
    if (InStr(hotkey, "^")) {
        if (explanation) {
            explanation .= " + "
        }
        explanation .= "Ctrl"
        hotkey := StrReplace(hotkey, "^")  ; Loại bỏ Ctrl
    }

    ; Kiểm tra phím Windows (LWin và RWin)
    if (InStr(hotkey, "#")) {
        if (explanation) {
            explanation .= " + "
        }
        explanation .= "Windows"
        hotkey := StrReplace(hotkey, "#")  ; Loại bỏ Windows
    }

    ; Kiểm tra các phím còn lại (ví dụ: 's', 'x', v.v.)
    if (hotkey) {
        if (explanation) {
            explanation .= " + "
        }
        explanation .= StrUpper(hotkey)
    }

    return explanation
}

LoadHotkeys(filePath := "C:\Users\jackb\Documents\AutoHotkey\configs\hotkeys.ini", section := "") {
    hotkeys := Map()
    if (FileExist(filePath)) {
        if (section != "") {
            sectionData := IniRead(filePath, section)

            if (sectionData != "") {
                lines := StrSplit(sectionData, "`n")
                for line in lines {
                    if (line != "" && !RegExMatch(line, "^\s*;")) {
                        parts := StrSplit(line, "=")
                        if (parts.Length = 2) {
                            hotkeys[parts[1]] := parts[2]
                        }
                    }
                }
            } else {
                TrayTip("Section does not exist!")
            }
        }
        else {
            sections := IniRead(filePath)
            if (sections != "") {
                return sections
            } else {
                TrayTip("No sections found in the .ini file!")
            }
        }
    } else {
        TrayTip("INI file not found!")
    }

    return hotkeys
}