globalLogFile := "C:\Users\jackb\Documents\AutoHotkey\configs\log.txt"
errorLogFile := "C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt"
FileObj := FileOpen(globalLogFile, "w", "UTF-8")

WriteRaw(_FileObj, param := "") {
    try {
        try _FileObj.Write(param)
    }
    catch as Err {
        MsgBox "Error writing to file: " Err.Message
        FileOpen(errorLogFile, 'a').Write("Error writing to file: " Err.Message "`n")
    }
}

WriteIndentedLine(text := '', indent := 0, endt := '`n') {
    WriteRaw(FileObj, Repeat(indent) text endt)
}
w := WriteIndentedLine

WriteObjectType(obj, indent := 0, endl := true, endt := '`n') {
    WriteIndentedLine('<' Type(obj) '>', indent endl)
}
t := WriteObjectType

LogObjectFlat(_FileObj, obj, indent := "") {
    arr := (Type(obj) = "Object" ? obj.OwnProps() : obj)
    for key, value in arr {
        if (IsObject(value)) {
            WriteRaw(_FileObj, indent "[" key "]" ":")
            LogObjectFlat(_FileObj, value, indent "`t")
        } else {
            WriteRaw(_FileObj, indent "[" key "]" ": " value)
        }
    }
}

LogObjectToFile(_FileObj, obj, indent := "", mode := "w") {
    if (Type(_FileObj) = "String") {
        try _FileObj := FileOpen(_FileObj, mode)
        catch as Err {
            MsgBox "Can't open '" _FileObj "'."
                . "`n`n" Type(Err) ": " Err.Message
            return
        }
    }
    LogObjectFlat(_FileObj, obj)
    _FileObj.Close()
}

ArgsToString(compact := false, args*) {
    result := compact ? "[" : "[`n"
    for i, val in args {
        result .= ObjectToString(val, 1, compact)
        if (i < args.Length)
            result .= compact ? ", " : ",`n"
    }
    result .= compact ? "]" : "`n]"
    return result
}

ObjectToString(obj, indent := 0, compact := false) {
    str := ""
    pad := compact ? "" : "    "
    indentStr := compact ? "" : Repeat(indent, pad)

    if Type(obj) = "Array" {
        str .= compact ? "[" : "[`n"
        for i, val in obj {
            str .= indentStr . ObjectToString(val, indent + 1, compact)
            if (i < obj.Length)
                str .= compact ? ", " : ",`n"
        }
        str .= compact ? "]" : "`n" . Repeat(indent - 1, pad) . "]"
    } else if Type(obj) = "Object" {
        str .= compact ? "{" : "{`n"
        count := 0
        for key, val in obj.OwnProps() {
            count++
            keyStr := IsNumber(key) ? key : "`"" . key . "`""
            str .= indentStr . keyStr . ": " . ObjectToString(val, indent + 1, compact)
            if (count < ObjOwnPropCount(obj))
                str .= compact ? ", " : ",`n"
        }
        str .= compact ? "}" : "`n" . Repeat(indent - 1, pad) . "}"
    } else {
        str := IsNumber(obj) ? obj : "`"" . obj . "`""
    }

    return str
}

Repeat(count := 1, str := '`t') {
    out := ""
    loop count
        out .= str
    return out
}
