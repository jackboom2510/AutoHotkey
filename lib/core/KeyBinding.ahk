#Include <core\cJSON>
#Include <ui\HelpUI>
hotkeysJSON := "D:\Documents\AutoHotkey\configs\hotkeys.json"
scripts := cJSON.LoadFile(hotkeysJSON, "UTF-8")
TextAlign_widths := [2. 3, 5, 8, 15, 20]

BindingScript(input := A_ScriptName, hideTimer := 3) {
    if (input = "ALL") {
        for (script_id, script in scripts) {
            BindingScript_Internal(script_id)
        }
    }
    else {
        if (InStr(input, '.')) {
            input := StrSplit(input, '.')[1]
        }
        BindingScript_Internal(input)
    }
    return
    BindingScript_Internal(script) {
        if (!scripts.has(script)) {
            OutputDebug "⚠️ No hotkeys found for script: " script
            return false
        }
        for fn_id, fn in scripts[script] {
            if (fn_id = "Send") {
                for hk_id, hk in fn["hotkeys"] {
                    AssignHotkey(hk_id, "Send", hk)
                }
                continue
            }
            if (fn.has("isMethod") && fn["isMethod"] = true || InStr(fn_id, '.')) {
                fullFn := StrSplit(fn_id, '.')
                try {
                    fn_id := ObjBindMethod(%fullFn[1]%, fullFn[2])
                }
                catch as Err {
                    OutputDebug "❌ Error running when running " fullFn[1] '.' fullFn[2] ': ' Err.Message
                    FileOpen("D:\Documents\AutoHotkey\configs\error_log.txt", 'a').Write(
                        "Error writing to file: " Err.Message "`n")
                }
            }
            if (!fn.has("args")) {
                if (fn.has("hotkeys"))
                    AssignHotkey(fn["hotkeys"][1], fn_id)
                continue
            }
            for args_id, args in fn["args"] {
                if (IsObject(args)) {
                    if (fn.has("hotkeys"))
                        AssignHotkey(fn["hotkeys"][args_id], fn_id, args*)
                } else {
                    if (fn.has("hotkeys"))
                        AssignHotkey(fn["hotkeys"][args_id], fn_id, args)
                }
            }
        }
        return true
    }
}

AssignHotkey(_hotkey, Function, FnArgs*) {
    if ((Function = Send || Function = "Send")) {
        if FnArgs[1].has("key") {
            if FnArgs[1].has("condition") {
                HotIf (*) => citeria(FnArgs[1]["condition"])
                AssignHotkey_Internal(_hotkey, Function, FnArgs[1]["key"])
                HotIf
            }
            else {
                AssignHotkey_Internal(_hotkey, Function, FnArgs[1]["key"])
            }
        }
        return
    }
    if (_hotkey.has("key")) {
        if (_hotkey.has("condition")) {
            HotIf (*) => citeria(_hotkey["condition"])
            AssignHotkey_Internal(_hotkey["key"], Function, FnArgs*)
            HotIf
        }
        else {
            AssignHotkey_Internal(_hotkey["key"], Function, FnArgs*)
        }
    }
    citeria(Expression, *) {
        if (Expression is string) {
            Expression := %Expression%()
        }
        else if (Expression is Func)
            Expression := Expression()
        else if (Expression is Array) {
            exps := Expression.Clone()
            Expression := true
            for idx, exp in exps {
                if (exp is String) {
                    exp := %exp%
                    Expression := Expression && exp()
                }
                else if (exp is Func)
                    Expression := Expression && exp()
                else if (exp is Array) {
                    if (exp[1] is string)
                        exp[1] := %exp[1]%
                    if (exp.Length = 1)
                        Expression := Expression && exp[1]()
                    else {
                        if (!IsObject(exp[2]))
                            Expression := Expression && exp[1](exp[2])
                        else
                            Expression := Expression && exp[1](exp[2]*)
                    }
                }
            }
        }
        return Expression
    }
    AssignHotkey_Internal(_Hotkey, Function, FnArgs*) {
        if (_Hotkey = "" || Trim(_Hotkey) = "") {
            OutputDebug "⚠️ Không thể gán hotkey vì không có KeyName hợp lệ."
            return false
        }
        if (Type(Function) = "String") {
            Function := %Function%
        }
        if !IsObject(Function) || !Function.HasMethod("Call") {
            OutputDebug "❌ Callback không hợp lệ."
            return false
        }

        ; try Hotkey(_Hotkey, "Off")
        try {
            Hotkey(_Hotkey, (*) => Function(FnArgs*))
            return true
        } catch as e {
            OutputDebug("❌ Lỗi khi gán hotkey `"" _Hotkey "`" cho <" Type(Function) ">`"" Function.Name "`":`n - " e.Message
            )
            return false
        }
    }
}

ShowHotkeys(input := A_scriptName, hideTimer := 0, lineLimit := 4) {
    if (input = "All") {
        for script_id, script in scripts {
            ShowHotkeys_Internal(script_id, hideTimer, lineLimit)
        }
        return
    } else if (InStr(input, '.')) {
        input := StrSplit(input, '.')[1]
    }
    if !scripts.Has(input) {
        OutputDebug "❌ Không tìm thấy script: " input
        return
    }
    ShowHotkeys_Internal(input, hideTimer, lineLimit)
    ShowHotkeys_Internal(scriptName, hideTimer := 0, lineLimit := 4) {
        script := scripts[scriptName]
        sectionGroupsMap := GroupHotkeys(script)

        sectionsForGui := []
        for name, data in sectionGroupsMap {
            sectionsForGui.Push({ title: name, unconditionalLines: data.unconditionalLines, conditionalLines: data.conditionalLines })
        }

        static g_scriptHotkeysHelpGuiInstance := ""
        if (!IsObject(g_scriptHotkeysHelpGuiInstance) || !WinExist('ahk_id ' g_scriptHotkeysHelpGuiInstance.gui.hwnd)) {
            g_scriptHotkeysHelpGuiInstance := HelpUI("🧩 Hotkeys cho script: " scriptName, sectionsForGui, hideTimer,
                lineLimit)
        } else {
            ; Nếu GUI đã tồn tại, bạn có thể muốn cập nhật nội dung của nó thay vì tạo lại.
            ; Việc cập nhật nội dung cho bố cục lưới này sẽ phức tạp hơn.
            ; Hiện tại, chúng ta chỉ toggle nó.
        }
        g_scriptHotkeysHelpGuiInstance.Toggle()
    }
}

GroupHotkeys(script) {
    sectionGroups := Map()
    for fn_id, fn in script {
        if (fn_id = "Send") {
            for hk_id, hk in fn["hotkeys"] {
                hotkeyStr := reghk(hk_id)
                display := IsObject(hk) ? hk["key"] : hk
                line := TextAlign(hotkeyStr) " → " reghk(display)
                isConditional := IsObject(hk) && hk.Has("condition")
                sectionName := fn["section"]
                if !sectionGroups.Has(sectionName)
                    sectionGroups[sectionName] := { unconditionalLines: [], conditionalLines: [] }

                if (isConditional) {
                    sectionGroups[sectionName].conditionalLines.Push(line)
                } else {
                    sectionGroups[sectionName].unconditionalLines.Push(line)
                }
            }
            continue
        }

        sectionName := fn["section"]
        if !sectionGroups.Has(sectionName)
            sectionGroups[sectionName] := { unconditionalLines: [], conditionalLines: [] }

        name := fn.Has("description") ? fn["description"] : fn_id
        hasSimilar := fn.Has("hasSimilar") && fn["hasSimilar"]

        if (hasSimilar = 1) {
            entries := []
            for hkEntry in fn["hotkeys"] {
                key := IsObject(hkEntry) ? hkEntry["key"] : hkEntry
                entries.Push(reghk(key))
            }
            argsText := fn.Has("args") ? (JoinArgs(", ", fn["args"]*)) : ""

            line := TextAlign(JoinArgs(" / ", entries*)) " → " name (argsText ? " (" argsText ")" : "")
            sectionGroups[sectionName].unconditionalLines.Push(line)

        } else {
            for i, hkEntry in fn["hotkeys"] {
                key := IsObject(hkEntry) ? hkEntry["key"] : hkEntry
                isConditional := IsObject(hkEntry) && hkEntry.Has("condition") && hkEntry["condition"] =
                "GetScriptStatus"
                argText := fn.Has("args") ? (
                    IsObject(fn["args"][i]) ? JoinArgs(", ", fn["args"][i]*) : fn["args"][i]
                ) : ""
                line := TextAlign(reghk(key)) " → " name (argText ? " (" argText ")" : "")
                if (isConditional) {
                    sectionGroups[sectionName].conditionalLines.Push(line)
                } else {
                    sectionGroups[sectionName].unconditionalLines.Push(line)
                }
            }
        }
    }
    return sectionGroups
}

Save(inputJSON := hotkeysJSON, outputJSON := hotkeysJSON, _scripts := scripts) {
    cJSON.DumpFile(_scripts, outputJSON, 1)
    PrettifyJSON(outputJSON, outputJSON)
}

AddCiteria() {
    citeria := "GetScriptStatus"
    for scripts_idx, script in scripts {
        for fn_name, fn in script {
            if (!fn.Has("section")) {
                fn["section"] := "Other"
            }
            if (fn_name = "Send") {
                for hks_key, hk in fn["hotkeys"] {
                    if (Type(fn["hotkeys"][hks_key]) = "Map")
                        continue
                    hk_clone := Map()
                    if (IsObject(hk)) {
                        hk_clone["key"] := hk[1]
                        hk_clone["condition"] := citeria
                    }
                    else {
                        hk_clone["key"] := hk
                    }
                    try {
                        OutputDebug "- Success convert " fn_name ": " _pl(fn["hotkeys"][hks_key])
                        fn["hotkeys"][hks_key] := hk_clone
                    }
                    catch as err {
                        OutputDebug "- Fail convert " fn_name ": " _pl(fn["hotkeys"][hks_key]) "`n`t- Err: " err.Message
                        continue
                    }
                }
                continue
            }
            if (fn.has("args")) {

                for args_idx, arg in fn["args"] {
                    if (Type(fn["hotkeys"][args_idx]) = "Map")
                        continue
                    hk_clone := Map()
                    hk := fn["hotkeys"][args_idx]
                    if (IsObject(hk)) {
                        hk_clone["key"] := hk[1]
                        hk_clone["condition"] := citeria
                    }
                    else {
                        hk_clone["key"] := hk
                    }
                    try {
                        OutputDebug "- Success convert " fn_name ": " _pl(fn["hotkeys"][hks_key])
                        fn["hotkeys"][args_idx] := hk_clone
                    }
                    catch as err {
                        OutputDebug "- Fail convert " fn_name ": " _pl(fn["hotkeys"][args_idx]) "`n`t- Err: " err.Message
                        continue
                    }
                }
            }
            else {

                if (Type(fn["hotkeys"][1]) = "Map")
                    continue
                hk_clone := Map()
                hk := fn["hotkeys"][1]
                if (IsObject(hk)) {
                    hk_clone["key"] := hk[1]
                    hk_clone["condition"] := citeria
                }
                else {
                    hk_clone["key"] := hk
                }
                try {
                    OutputDebug "- Success convert " fn_name ": " fn["hotkeys"][1]
                    fn["hotkeys"][1] := hk_clone
                }
                catch as err {
                    OutputDebug "- Fail convert " fn_name ": " fn["hotkeys"][1] "`n`t- Err: " err.Message
                    continue
                }
            }
        }
    }
    Save
}
