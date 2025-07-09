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
HK(hotkey) {
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

AssignHotkey(KeyName, Callback, Options := "", Default := "") {

    if (KeyName = "" || Trim(KeyName) = "") {
        KeyName := Default
    }

    if (KeyName = "" || Trim(KeyName) = "") {
        TrayTip "⚠️ Không thể gán hotkey vì không có KeyName hợp lệ."
        return false
    }

    try Hotkey(KeyName, "Off")

    try {
        Hotkey(KeyName, Callback, Options)
        return true
    } catch Error {
        TrayTip "❌ Lỗi khi gán hotkey '" KeyName "':`n" Error.Message
        return false
    }
}
