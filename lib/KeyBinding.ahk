#Include <JSON>
#Include <HelpGui>
#SingleInstance Force
hotkeysJSON := "C:\Users\jackb\Documents\AutoHotkey\configs\hotkeys.json"
scripts := JSON.LoadFile(hotkeysJSON, "UTF-8")
TextAlign_widths := [3, 15, 20]

Convert() {
    citeria := "GetScriptStatus"
    for scripts_idx, script in scripts {
        for fn_name, fn in script {
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

NormalizeHotkeys() {
    for script_id, script in scripts {
        for fn_id, fn in script {
            if (!fn.Has("section")) {
                fn["section"] := "Other"
            }
        }
    }
}

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
                    AssignBoundHotkey(hk_id, "Send", hk)
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
                    FileOpen("C:\Users\jackb\Documents\AutoHotkey\configs\error_log.txt", 'a').Write(
                        "Error writing to file: " Err.Message "`n")
                }
            }
            if (!fn.has("args")) {
                AssignBoundHotkey(fn["hotkeys"][1], fn_id)
                continue
            }
            for args_id, args in fn["args"] {
                if (IsObject(args)) {
                    AssignBoundHotkey(fn["hotkeys"][args_id], fn_id, args*)
                } else {
                    AssignBoundHotkey(fn["hotkeys"][args_id], fn_id, args)
                }
            }
        }
        return true
    }
}

AssignBoundHotkey(_hotkey, Function, FnArgs*) {
    citeria(Expression) {
        if (Type(Expression) = "string")
            Expression := %Expression%
        return Expression
    }
    if ((Function = Send || Function = "Send") && FnArgs.length = 1) {
        if FnArgs[1].has("condition") {
            HotIf citeria(FnArgs[1]["condition"])
            AssignHotkey(_hotkey, Function, FnArgs[1]["key"])
            Hotif
        }
        else {
            AssignHotkey(_hotkey, Function, FnArgs[1]["key"])
        }
        return
    }
    if (_hotkey.has("condition")) {
        HotIf citeria(_hotkey["condition"])
        AssignHotkey(_hotkey["key"], Function, FnArgs*)
        Hotif
    }
    else
        AssignHotkey(_hotkey["key"], Function, FnArgs*)
}

AssignHotkey(_Hotkey, Function, FnArgs*) {
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

    try Hotkey(_Hotkey, "Off")
    try {
        Hotkey(_Hotkey, (*) => Function(FnArgs*))
        return true
    } catch as e {
        OutputDebug("❌ Lỗi khi gán hotkey `"" _Hotkey "`" cho <" Type(Function) ">`"" Function.Name "`":`n - " e.Message
        )
        return false
    }
}

ShowScriptHotkeysUI(input := A_scriptName, hideTimer := 0, lineLimit := 10) {
    if (input = "All") {
        for script_id, script in scripts {
            ShowScriptHotkeysUI_Internal(script_id, hideTimer, lineLimit)
        }
    }
    else if (InStr(input, '.')) {
        input := StrSplit(input, '.')[1]
    }
    if !scripts.Has(input) {
        OutputDebug "❌ Không tìm thấy script: " input
        return
    }
    ShowScriptHotkeysUI_Internal(input, hideTimer, lineLimit)
    return
    ShowScriptHotkeysUI_Internal(script, hideTimer := 0, lineLimit := 10) {
        script := scripts[input]
        sectionGroups := GroupHotkeysAdvanced(script)

        preferredOrder := [
            "🖥️ MONITOR & PEN SETTINGS",
            "🔁 AUTO SEND",
            "🎛 TOGGLE KEYS",
            "📋 UTILITIES",
            "🔧 ADDITIONAL FEATURES",
            "⚙️ HOTKEYS CONDITIONED BY SCRIPT STATUS"
        ]

        sections := []

        for name in preferredOrder {
            if sectionGroups.Has(name) {
                sections.Push({ title: name, lines: sectionGroups[name] })
                sectionGroups.Delete(name)
            }
        }
        for name, lines in sectionGroups {
            sections.Push({ title: name, lines: lines })
        }
        if !IsSet(g_scriptHotkeysHelpGuiInstance) {
            ; If not, create it for the first time
            static g_scriptHotkeysHelpGuiInstance := HelpGui("🧩 Hotkeys cho script: " input, sections, hideTimer,
                lineLimit)
        } else {
            ; If it already exists, update its content if necessary (optional, but good for dynamic content)
            ; For simplicity, we'll just toggle it. If content needs to change, you'd need methods in HelpGui to update sections.
            ; For now, assume content is relatively static or re-creating it is fine if you modify the sections logic.
            ; If you want to update content, you'd need to add a method like 'UpdateContent(newSections)' to HelpGui.
            ; For this example, we assume the content is generated once.
        }

        ; Now, toggle the visibility of the *existing* instance
        g_scriptHotkeysHelpGuiInstance.Toggle
    }
}

GroupHotkeysAdvanced(script) {
    sectionGroups := Map()

    for fn_id, fn in script {
        if (fn_id = "Send") {
            for hk_id, hk in fn["hotkeys"] {
                hotkeyStr := hkexp(hk_id)
                display := IsObject(hk) ? hk["key"] : hk
                line := TextAlign(hotkeyStr) " → "
                . hkexp(display)
                section := (IsObject(hk) && hk.Has("condition")) ? "⚙️ HOTKEYS CONDITIONED BY SCRIPT STATUS" : fn[
                    "section"]
                if !sectionGroups.Has(section)
                    sectionGroups[section] := []
                sectionGroups[section].Push(line)
            }
            continue
        }

        section := fn["section"]
        if !sectionGroups.Has(section)
            sectionGroups[section] := []

        name := fn.Has("description") ? fn["description"] : fn_id
        hasSimilar := fn.Has("hasSimilarReturn") && fn["hasSimilarReturn"]

        if (hasSimilar = 1) {
            entries := []
            for hkEntry in fn["hotkeys"] {
                key := IsObject(hkEntry) ? hkEntry["key"] : hkEntry
                entries.Push(hkexp(key))
            }
            argsText := fn.Has("args") ? (
                JoinArgs(", ", fn["args"]*)
            ) : ""
            sectionGroups[section].Push(
                TextAlign(JoinArgs(" / ", entries*)) " → " name (argsText ? " (" argsText ")" : "")
            )
        } else {
            for i, hkEntry in fn["hotkeys"] {
                key := IsObject(hkEntry) ? hkEntry["key"] : hkEntry
                cond := (IsObject(hkEntry) && hkEntry.Has("condition"))
                effectiveSection := cond ? "⚙️ HOTKEYS CONDITIONED BY SCRIPT STATUS" : section
                if !sectionGroups.Has(effectiveSection)
                    sectionGroups[effectiveSection] := []
                argText := fn.Has("args") ? (
                    IsObject(fn["args"][i]) ?
                        JoinArgs(", ", fn["args"][i]*) :
                        fn["args"][i]
                ) : ""
                sectionGroups[effectiveSection].Push(TextAlign(hkexp(key)) " → " name (argText ? " (" argText ")" : ""))
            }
        }
    }

    return sectionGroups
}

Save(inputJSON := hotkeysJSON, outputJSON := hotkeysJSON, _scripts := scripts) {
    JSON.DumpFile(_scripts, outputJSON, 1)
    PrettifyJSON(outputJSON, outputJSON)
}

; ShowAllScriptsFunctionsGUI() {
;     myGui := gui("+AlwaysOnTop + Resize", "All Scripts Functions")
;     myGui.SetFont("s10")

;     checkboxes := Map() ; Map[script][fn_id] = checkbox control

;     y := 10
;     margin := 10
;     lineHeight := 30
;     sectionSpacing := 10

;     for scriptName, script in scripts {
;         ; Tạo GroupBox làm section
;         myGui.Add("GroupBox", "x10 y" y " w250 h" (lineHeight * (script.Count + 1)), scriptName)
;         y += 30

;         checkboxes[scriptName] := Map()

;         for fn_id, fn_data in script {
;             if (fn_id = "Send")
;                 continue

;             ; Thêm checkbox cho hàm
;             cb := myGui.AddCheckbox("x30 y" y " w250 v" scriptName "_" fn_id, fn_id)
;             checkboxes[scriptName][fn_id] := cb
;             y += lineHeight
;         }
;         y += sectionSpacing
;     }
;     myGui.Show()
; }

; ShowScriptFunctionGUI(script) {
;     if (!scripts.Has(script)) {
;         MsgBox "⚠️ Script '" script "' not found in JSON."
;         return
;     }

;     myGui := gui("+AlwaysOnTop", "Functions for " script)
;     myGui.SetFont("s10")
;     checkboxes := Map()

;     for fn_id, fn_data in scripts[script] {
;         if (fn_id = "Send")
;             continue

;         label := fn_id
;         cb := myGui.AddCheckbox("v" label, label)
;         checkboxes[fn_id] := cb
;     }
;     myGui.Show("AutoSize Center")
; }



; GroupHotkeysByDisplayGroup(script) {
;     groupMap := Map()

;     for fn_id, fn in script {
;         groupName := fn.Has("displayGroup") ? fn["displayGroup"] : ""
;         if (groupName = "") {
;             continue
;         }

;         entries := []
;         if fn.Has("args") {
;             for i, args in fn["args"] {
;                 hk := fn["hotkeys"][i]
;                 hotkeyStr := IsObject(hk) ? hk[1] : hk
;                 entries.Push(hkexp(hotkeyStr))
;             }
;         } else {
;             hk := fn["hotkeys"]
;             hotkeyStr := IsObject(hk) ? hk[1] : hk
;             entries.Push(hkexp(hotkeyStr))
;         }

;         combinedHotkeys := JoinArgs(" / ", entries*)
;         if !groupMap.Has(groupName)
;             groupMap[groupName] := []

;         groupMap[groupName].Push(combinedHotkeys " → " groupName)
;     }

;     return groupMap
; }

; GroupHotkeysBySection(script) {
;     sectionGroups := Map()

;     for fn_id, fn in script {
;         if (fn_id = "Send") {
;             if !sectionGroups.Has("Other")
;                 sectionGroups["Other"] := []
;             for hk_id, hk in fn["hotkeys"] {
;                 display := IsObject(hk) ? hk[1] : hk
;                 sectionGroups["Other"].Push(TextAlign(hkexp(hk_id)) " → " hkexp(display))
;             }
;             continue
;         }

;         section := fn["section"]
;         if !sectionGroups.Has(section)
;             sectionGroups[section] := []

;         name := fn.Has("description") ? fn["description"] : fn_id
;         if fn.Has("args") {
;             for i, args in fn["args"] {
;                 hk := fn["hotkeys"][i]
;                 hotkeyStr := IsObject(hk) ? hk[1] : hk
;                 argText := IsObject(args) ? JoinArgs(", ", args*) : args
;                 sectionGroups[section].Push(TextAlign(hkexp(hotkeyStr)) " → " name " (" argText ")")
;             }
;         } else {
;             hk := fn["hotkeys"]
;             hotkeyStr := IsObject(hk) ? hk[1] : hk
;             sectionGroups[section].Push(TextAlign(hkexp(hotkeyStr)) " → " name)
;         }
;     }

;     return sectionGroups
; }
