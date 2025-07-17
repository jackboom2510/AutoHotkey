globalLogFile := "C:\Users\jackb\Documents\AutoHotkey\configs\log.txt"
globalLogJson := "C:\Users\jackb\Documents\AutoHotkey\configs\log.json"
errorLogFile := "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
TextAlign_widths := [1, 3, 5, 7, 9, 10, 14, 16, 17, 20, 24]

erf := EraseFile
hkexp := HotkeyExp
fm := _Format
_fma := _Format.Bind(',`n', 0, 'args')
_pl := _Format.Bind(',`n', 0, 'plain')
_t := _Format.Bind(, 0, 't')
_pr := _Format.Bind(, 0, 'pr')

_w := WriteFile.Bind(globalLogFile, ',`n', 0, 'args')
_wl := WriteFile.Bind(globalLogFile, , , 'l')
_wt := WriteFile.Bind(globalLogFile, , 0, 't')
_wr := WriteFile.Bind(globalLogFile, , , 'r')
_we := WriteFile.Bind(errorLogFile, , , 'l')

EraseFile(file := globalLogFile) {
    try file := FileOpen(file, 'w')
    catch as Err {
        TrayTip "Can't open '" file "'."
            . "`n`n" Type(Err) ": " Err.Message
        return false
    }
    try {
        file.Close()
    }
}

OpenFile(file := globalLogFile, mode := "a", encoding := "UTF-8") {
    try {
        return FileOpen(file, mode, encoding)
    }
    catch as Err {
        TrayTip "Can't open '" file "'."
            . "`n`n" Type(Err) ": " Err.Message
        return false
    }
}

/**
 * @description Tạo chuỗi đã định dạng dựa trên `Flags` và ghi vào file `log.txt`.
 * @param {(String)} file Tên file ghi log. Mặc định là biến toàn cục `globalLogFile`.  
 * @param {(Any)} [input=';`n`n']
 * - Chuỗi hoặc đối tượng cần định dạng.
 * - Định dạng phân cách cho chuỗi trả về trong chế độ định dạng kiểu `'args'`.
 * @param {(Number)} [indent=0] Mức thụt lề, số lần ký tự tab lặp lại.  
 * @param {(Number|String)} [Flags='args'] Cờ định dạng chuỗi khi ghi, có thể là chuỗi ký tự hoặc số nguyên.  
 * |  DEC  | `Flags`     | `Allias`   | Mô tả                                                       |
 * | :---: |:-----------:|:----------:|:-----------------------------------------------------------|
 * | `0`   | `"raw"`     |  `"r"`     | Raw: Trả về chuỗi thô không thêm xuống dòng                 |
 * | `1`   | `"prime"`   |  `"pr"`    | Prime: Trả về chuỗi với định dạng như sau: `"obj"`          |
 * | `2`   | `"line"`    |  `"l"`     | Line: Chuỗi + xuống dòng (`\n`)                             |
 * | `3`   | `"tab"`     |  `"t"`     | Tab: Chuỗi + tab (`\t`)                                     |
 * | `4`   | `"type"`    |  `"t"`     | Kiểu dữ liệu: Trả về chuỗi dạng `<Type(obj)>`               |
 * | `5`   |  `"obj"`    |  `"o"`     | Đối tượng dạng đầy đủ, nhiều dòng (không compact)           |
 * | `6`   | `"cp_obj"`  |  `"cpo"`   | Đối tượng compact, gọn hơn                                   |
 * | `7`   | `"pl_obj"`  |  `"plo"`   | Đối tượng dạng thuần túy, không có dấu ngoặc hoặc xuống dòng |
 * | `8`   | `"args"`    |  `"a"`     | Định dạng nhiều tham số dưới dạng mảng (không compact)       |
 * | `9`   | `"cp_args"` |  `"cpa"`   | Định dạng nhiều tham số dạng compact                         |
 * | `10`  | `"pl_args"` |  `"pla"`   | Nhiều tham số dạng chuỗi thuần túy, phân tách bằng dấu phẩy  |
 * @param {Any} args
 * - Danh sách các đối tượng dùng cho chế độ định dạng `"args"`, `"cp_args"` và `"pl_args"`
 * - Tên File / Tên Obj cho chế độ định dạng `"type"`
 */
WriteFile(file := globalLogFile, input := ';`n', indent := 0, Flags := 'args', args*) {
    FileObj := OpenFile(file)
    str := _Format(input, indent, Flags, args*)
    FileObj.Write(str)
    if (Flags = 'json' || Flags = 'js')
        PrettifyJSON(file, file)
    FileObj.Close()
}

/**
 * @description Định dạng chuỗi hoặc đối tượng theo kiểu định sẵn dựa trên cờ (`flag`) được chọn.
 * @param {(Any)} [input=';`n`n']
 * - Chuỗi hoặc đối tượng cần định dạng.
 * - Định dạng phân cách cho chuỗi trả về trong chế độ định dạng kiểu `'args'`.
 * @param {Number} [indent=0] Số lần lặp lại ký tự tab (`Repeat`) dùng để thụt lề.  
 * @param {(Number|String)} [Flags='args'] Chế độ định dạng hoặc cờ xác định kiểu định dạng.
 * |  DEC  | `Flags`     | `Allias`   | Mô tả                                                       |
 * | :---: |:-----------:|:----------:|:------------------------------------------------------------|
 * | `0`   | `"raw"`     |  `"r"`     | Raw: Trả về chuỗi thô không thêm xuống dòng                 |
 * | `1`   | `"prop"`    |  `"pr"`    | Prop: Trả về chuỗi với định dạng như sau: `"obj": "arg[1]"`  |
 * | `2`   | `"line"`    |  `"l"`     | Line: Chuỗi + xuống dòng (`\n`)                             |
 * | `3`   | `"tab"`     |  `"t"`     | Tab: Chuỗi + tab (`\t`)                                     |
 * | `4`   | `"type"`    |  `"t"`     | Kiểu dữ liệu: Trả về chuỗi dạng `<Type(obj)>`               |
 * | `5`   |  `"obj"`    |  `"o"`     | Đối tượng dạng đầy đủ, nhiều dòng (không compact)           |
 * | `6`   | `"cp_obj"`  |  `"cpo"`   | Đối tượng compact, gọn hơn                                   |
 * | `7`   | `"pl_obj"`  |  `"plo"`   | Đối tượng dạng thuần túy, không có dấu ngoặc hoặc xuống dòng |
 * | `8`   | `"args"`    |  `"a"`     | Định dạng nhiều tham số dưới dạng mảng (không compact)       |
 * | `9`   | `"cp_args"` |  `"cpa"`   | Định dạng nhiều tham số dạng compact                         |
 * | `10`  | `"pl_args"` |  `"pla"`   | Nhiều tham số dạng chuỗi thuần túy, phân tách bằng dấu phẩy  |
 * @param {Any} args
 * - Danh sách các đối tượng dùng cho chế độ định dạng `"args"`, `"cp_args"` và `"pl_args"`
 * - Tên File / Tên Obj cho chế độ định dạng `"type"`
 * @returns {String} Chuỗi đã được định dạng theo kiểu đã chọn.  
 */
_Format(input := ',`n', indent := 0, Flags := 'args', args*) {
    switch Flags {
        case 0, 'pr', 'prop':
            key := (!IsObject(input)) ? "`"" input "`": " : ""
            val := (args.Length = 1 && !IsObject(args[1])) ? ("`"" args[1] "`"") : ""
            return Repeat(indent) key val
        case 1, 'r', 'raw':
            return Repeat(indent) input
        case 2, 'l', 'line':
            return Repeat(indent) input '`n'
        case 3, 'tb', 'tab':
            return Repeat(indent) input '`t'
        case 4, 't', 'ty', 'type':
            typo := "`"" Type(input) "`""
            ; output := ""
            if(Type(input = "Func")) {
                output := "`"" input.name "`""
                return Repeat(indent) "{" typo ": " output "}" '`n'
            }
            ; else if (!IsObject(input)) {
            ;     output := input
            ;     return Repeat(indent) "{" typo ": " output "}"
            ; }
            ; output := SingleFormat(input, indent+1)
            ; return Repeat(indent) "{" Format("`"{}`":`n{}", Type(input), output) Repeat(indent) "}"
            return Repeat(indent) '<' typo '>`n'
        case 5, 'obj1', 'o1', 'obj', 'o':
            return SingleFormat(input, indent, "pretty")
        case 6, 'obj2', 'o2', 'cp_obj', 'cpo', :
            return SingleFormat(input, indent, "compact")
        case 7, 'obj3', 'o3', 'pl_obj', 'plo':
            return SingleFormat(input, indent, "plain")
        case 8, 'args1', 'a1', 'args', 'a', 'pretty', 'js', 'json':
            return MultipleFormat(input, indent, "pretty", args*)
        case 9, 'args2', 'a2', 'cp_args', 'cpa', 'compact':
            return MultipleFormat(input, indent, "compact", args*)
        case 10, 'args3', 'a3', 'pl_args', 'pla', 'plain':
            return MultipleFormat(input, indent, "plain", args*)

        default:
            return Repeat(indent) input Flags
    }
    return ""
}

SingleFormat(obj, indent := 0, mode := "pretty", sep := ',') {
    SingleFormat_Internal(obj, indent := 0, mode := "pretty", sep := ",") {
        compact := (mode = "compact")
        plain := (mode = "plain")

        str := ""
        openBracket := plain ? "`n" : (compact ? "[" : "[`n")
        closeBracket := plain ? "`n" Repeat(indent) "" : (compact ? "]" : "`n" Repeat(indent) "]")
        openBrace := plain ? "`n" : (compact ? "{" : "{`n")
        closeBrace := plain ? "`n" Repeat(indent) "" : (compact ? "}" : "`n" Repeat(indent) "}")

        if Type(obj) = "Array" {
            str .= openBracket
            for , val in obj {
                valStr := SingleFormat_Internal(val, indent + 1, mode)
                str .= compact ? valStr : (Repeat(indent + 1) . valStr)
                if (A_index < obj.Length)
                    str .= compact ? sep " " : sep "`n"
            }
            str .= closeBracket

        } else if (Type(obj) = "Map" || Type(obj) = "Object") {
            props := (Type(obj) = "Map") ? obj : obj.OwnProps()
            count := (Type(obj) = "Map") ? obj.Count : ObjOwnPropCount(obj)
            str .= openBrace
            for key, val in props {
                keyStr := "`"" key "`""
                valStr := SingleFormat_Internal(val, indent + 1, mode)
                str .= compact ? (keyStr ": " valStr) : (Repeat(indent + 1) . keyStr ": " . valStr)
                if (A_Index < count)
                    str .= compact ? sep " " : sep "`n"
            }
            str .= closeBrace

        } else {
            str := obj
        }
        return str
    }
    output := Repeat(indent) SingleFormat_Internal(obj, indent, mode, sep)
    cleaned := []
    for , line in StrSplit(output, "`n") {
        if (Trim(line) = "")
            continue
        if (mode = "plain" && SubStr(line, 1, 1) = "`t")
            line := SubStr(line, 2)
        cleaned.Push(line)
    }
    output := ""
    for line in cleaned {
        output .= line
        if (A_index < cleaned.Length)
            output .= "`n"
    }
    return output
}

MultipleFormat(sep := ',`n', indent := 0, mode := "pretty", args*) {
    if (args.length = 1)
        return SingleFormat(args[1], indent, mode, sep)
    if (mode = "plain") {
        result := ""
        for val in args {
            str := (IsObject(val) ? SingleFormat(val, indent, mode) : val)
            if (A_index < args.Length)
                result .= str sep
        }
        return result
    }
    compact := (mode = "compact")
    result := (compact ? "[" : "[`n")
    for val in args {
        line := Repeat(indent) SingleFormat(val, indent + 1, mode)
        result .= (compact ? line : (Repeat(indent) line))
        if (A_index < args.Length)
            result .= compact ? (RTrim(sep, '`n') " ") : (sep)
    }
    result := Repeat(indent) result (compact ? "]" : "`n]")
    return result
}

/**
 * @description Aligns a string based on a width list and alignment mode.  
 * Useful for formatting columns of varying widths. Automatically picks the first width that fits the text length.  
 * 
 * @param {String} text  
 * The text to be aligned.
 * 
 * @param {Array<Number>} [widths=[1, 3, 6, 8, 15, 17, 20]]  
 * Sorted list of increasing widths to try aligning to.  
 * The first width greater than or equal to the text length will be used.
 * 
 * @param {'l'|'r'|'m'|'ml'|'mr'|'fixed'} [align='l']  
 * Alignment mode:
 * 
 * | Mode     | Full Name         | Padding Distribution                  | Description                                      |
 * |----------|-------------------|---------------------------------------|--------------------------------------------------|
 * | `'l'`    | Left              | `[text][padding]`                     | Align to left                                    |
 * | `'r'`    | Right             | `[padding][text]`                     | Align to right                                   |
 * | `'m'`    | Middle            | `[half pad][text][half pad]`          | Center-aligned                                   |
 * | `'ml'`   | Mid-Left          | `[2/3 pad][text][1/3 pad]`            | Leaning left center                              |
 * | `'mr'`   | Mid-Right         | `[1/3 pad][text][2/3 pad]`            | Leaning right center                             |
 * | `'fixed'`| Fixed Position    | Based on `fixedRanges` and `anchor`   | Stick to edge of predefined width range          |
 * 
 * @param {String} [padChar=' ']  
 * Character used to pad the text. Usually space or `.` or `-`.
 * 
 * @param {Array<[Number, Number]>} [fixedRanges=[]]  
 * Used only in `'fixed'` mode. Array of fixed regions where text should be placed, e.g. `[[0, 10], [20, 30]]`.  
 * `text` will be placed at the beginning or end depending on `anchor`.
 * 
 * @param {'start'|'end'} [anchor='start']  
 * For `'fixed'` mode only. Determines whether text is anchored to the `start` or `end` of the fixed region.
 * 
 * @returns {String}  
 * A new string with the aligned text and appropriate padding.
 * 
 * @example <caption>Left align in the first fitting width.</caption>
 * TextAlign("OK", [5, 10]) ; => "OK   "
 * 
 * @example <caption>Right align, fixed width.</caption>
 * TextAlign("Done", [5, 10], "r") ; => "     Done"
 * 
 * @example <caption>Center align with pad.</caption>
 * TextAlign("Hello", [10], "m", "-") ; => "---Hello---"
 * 
 * @example <caption>Align to end of fixed range.</caption>
 * TextAlign("End", , "fixed", ".", [[0, 10]], "end") ; => ".......End"
 */
TextAlign(text, widths := TextAlign_widths, align := "l", padChar := " ", fixedRanges := [], anchor := "start") {
    textLen := StrLen(text)
    targetWidth := 0

    if (align = "fixed") {
        for , range in fixedRanges {
            if (textLen >= range[1] - range[0]) {
                continue
            }
            if (anchor = "start") {
                return Repeat(range[0], padChar) . text
            } else if (anchor = "end") {
                return text . Repeat(range[1] - range[0] - textLen, padChar)
            }
        }
        return text
    }

    for , w in widths {
        if (textLen <= w) {
            targetWidth := w
            break
        }
    }

    if (!targetWidth)
        return text

    padding := targetWidth - textLen

    switch align {
        case "r":
            return Repeat(padding, padChar) . text
        case "m":
            left := Floor(padding / 2)
            right := Ceil(padding / 2)
            return Repeat(left, padChar) . text . Repeat(right, padChar)
        case "ml":
            left := Floor(padding * 2 / 3)
            right := padding - left
            return Repeat(left, padChar) . text . Repeat(right, padChar)
        case "mr":
            left := Floor(padding / 3)
            right := padding - left
            return Repeat(left, padChar) . text . Repeat(right, padChar)
        default:
            return text . Repeat(padding, padChar)
    }
}

Repeat(count := 1, str := '`t') {
    if (count < 0)
        count := 0
    out := ""
    loop count
        out .= str
    return out
}

JoinArgs(sep := ", ", args*) {
    out := ""
    for i, v in args {
        out .= (i > 1 ? sep : "") (IsObject(v) ? _Format(v, 0, 'plain') : v)
    }
    return out
}

SortStringArrayByLength(arr, delimiter := "`n") {

    joined := JoinArgs(delimiter, arr*)

    sorted := Sort(joined, "D" delimiter, LengthSort)
    return StrSplit(sorted, delimiter)
}

LengthSort(a, b, *) {
    return StrLen(a) - StrLen(b)
}

PrettifyJSON(inputJSON := globalLogFile, outputJSON := globalLogFile, pythonScript :=
    "D:\5. Jack\#Learn\IT\Python\myenv\PrettifyJSON.py") {
    cmd := Format('py "{}" "{}" "{}"', pythonScript, inputJSON, outputJSON)
    try {
        Run cmd
    }
    catch as e {
        TrayTip("❌ Lỗi khi format file JSON `"" inputJSON "`" và xuất ra `"" outputJSON "`": " e.Message)
        return false
    }
}

; HotkeyExp(hotkey) {
;     explanation := ""
;     if (InStr(hotkey, "+")) {
;         explanation .= "Shift"
;         hotkey := StrReplace(hotkey, "+")
;     }
;     if (InStr(hotkey, "!")) {
;         if (explanation) {
;             explanation .= " + "
;         }
;         explanation .= "Alt"
;         hotkey := StrReplace(hotkey, "!")
;     }
;     if (InStr(hotkey, "^")) {
;         if (explanation) {
;             explanation .= " + "
;         }
;         explanation .= "Ctrl"
;         hotkey := StrReplace(hotkey, "^")
;     }
;     if (InStr(hotkey, "#")) {
;         if (explanation) {
;             explanation .= " + "
;         }
;         explanation .= "Windows"
;         hotkey := StrReplace(hotkey, "#")
;     }
;     if hotkey {
;         if explanation
;             explanation .= " + "
;         if RegExMatch(hotkey, "\{(.*)\}") {
;             hotkey := RegExReplace(hotkey, "\{}")
;         } else {
;             explanation .= StrUpper(SubStr(hotkey, 1, 1)) . SubStr(hotkey, 2)
;         }
;     }
;     return explanation
; }

HotkeyExp(hotkey) {
    explanation := ""
    hotkey := RegExReplace(hotkey, "(\+)", "Shift + ")
    hotkey := RegExReplace(hotkey, "(!)", "Alt + ")
    hotkey := RegExReplace(hotkey, "(\^)", "Ctrl + ")
    hotkey := RegExReplace(hotkey, "(#)", "Win + ")
    hotkey := RegExReplace(hotkey, "(Ctrl|Alt|Shift|Win)(?=\s*(Ctrl|Alt|Shift|Win))", "$1 + ")
    hotkey := RegExReplace(hotkey, "(Ctrl|Alt|Shift|Win)(?=\s*(Ctrl|Alt|Shift|Win))", "$1 + ")
    hotkey := RegExReplace(hotkey, "\{(.*)\}", "$1")
    hotkey := RegExReplace(hotkey, "\b(.)", "$U{1}")
    return hotkey
}