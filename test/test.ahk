#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <Log>
#Include <JSON>

logJson := "C:\Users\jackb\Documents\AutoHotkey\configs\log.json"
erf(logJson)

; scripts := JSON.LoadFile(logJson, "UTF-8")
erf

arr := [{
    123: "unkown",
    345: "unknow1",
    678: [6, 7, 8]
},
1,
[
    [21, "ConfigureOneNote", "ConfigureOneNote", [2], [3]],
    [15, "ConfigureOneNote", "ConfigureOneNote", [1], [2]],
    [16, "ConfigureOneNote", "ConfigureOneNote", [1], [5]]
]]

wtype(obj, indent) {
    typo := "`"" Type(obj) "`""
    output := ""
    if (Type(obj) = "Func") {
        output := "`"" obj.name "`""
        return Repeat(indent) "{" typo ": " output "}"
    }
    else if (!IsObject(obj)) {
        output := obj
        return Repeat(indent) "{" typo ": " output "}"
    }
    output := SingleFormat(obj, indent + 1)
    return Repeat(indent) "{" Format("`"{}`":`n{}", Type(obj), output) Repeat(indent) "}"
}


