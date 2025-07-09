#Include <JSON>
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

infile := "input.json"
outfile := "output.json"
logFile := "log.txt"

; Create an object with every supported data type
obj := {
    General: {
        Theme: "Dark",
        Frontsize: 14
    },
    Shortcuts: {
        Save: "Ctrl+S",
        Open: "Ctrl+O"
    }
}

; Convert to JSON
FileDelete(outfile)
FileAppend(JSON.Dump(obj), outfile)
; MsgBox JSON.Dump(obj) ; Expect: ["abc", 123, {"false": 0, "null": "", "true": 1}, [true, false, null]]
