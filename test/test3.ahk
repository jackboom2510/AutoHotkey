#Requires AutoHotkey v2.0
#Include <KeyBinding>
#Include <KeyModifier>
#Include <JSON>
#Include <ClickMacro>
#Include <StatusOverlay>
#Include <KeyModifier>
#Include <HelpGUI>
#SingleInstance Force
Persistent

infile := "input.json"
outfile := "output.json"
logFile := "log.txt"

obj := JSON.LoadFile(infile)
FileDelete(logFile)
FileOpen(logFile, "w", "UTF-8")

/*
(Map) obj
    (Map) Script
        (Map) Function:
            (Map) hotkeys
                (String Array) array_of_hotkeys
            (Map) args
                (String/Int Array) array_of_args
            (Map) description
                (String) description_value
*/
for Script in obj {
    for Function in obj[Script] {
        for idx, hk in obj[Script][Function]["hotkeys"] {
            ; FileAppend("AssignHotkey(`"" obj[Script][Function]["hotkeys"][idx] "`", ", logFile)
            ; FileAppend(Function, logFile)
            if (obj[Script][Function].Has("args")) {
                list_args := []
                ; FileAppend(' , , ,', logFile)
                if (IsObject(obj[Script][Function]["args"][idx])) {
                    ; out := "["
                    out := ""
                    for no_arg, var in obj[Script][Function]["args"][idx] {
                        list_args.Push(var)
                        ; out .= var
                        ; if (no_arg != obj[Script][Function]["args"][idx].length && obj[Script][Function]["args"][idx].length >
                        ;     1)
                        ; out .= ','
                    }
                    ; out .= "]"
                    ; FileAppend(out, logFile)

                    AssignHotkey(obj[Script][Function]["hotkeys"][idx], Function, , , list_args)
                }
                else {
                    ; FileAppend(obj[Script][Function]["args"][idx], logFile)

                    AssignHotkey(obj[Script][Function]["hotkeys"][idx], Function, , , obj[Script][Function]["args"][idx
                        ])
                }
            }
            else {
                AssignHotkey(obj[Script][Function]["hotkeys"][idx], Function)
            }
            ; FileAppend(")`n", logFile)
        }
    }
}
