#Include <JSON>
#Include <Log>
#Include <HelpGui>
#SingleInstance Force
hotkeysJSON := "C:\Users\jackb\Documents\AutoHotkey\configs\test_hotkeys.json"
scripts := JSON.LoadFile(hotkeysJSON, "UTF-8")

test_ShowScriptHotkeysUI

Save

GroupHotkeysAdvanced(script) {
    sectionGroups := Map()

    for fn_id, fn in script {
        if (fn_id = "Send") {
            ; for hk_id, val in fn["hotkeys"] {
            ;     entries := IsObject(val) ? val : [val]
            ;     for i, v in entries {
            ;         hotkeyStr := hkexp(hk_id)
            ;         display := IsObject(v) ? v["key"] : v
            ;         line := TextAlign(hotkeyStr) " → " hkexp(display)
            ;         section := (IsObject(v) ; && v.Has("condition");
            ;         ) ? "⚙️ HOTKEYS CONDITIONED BY SCRIPT STATUS" : fn["section"]
            ;         if !sectionGroups.Has(section)
            ;             sectionGroups[section] := []
            ;         sectionGroups[section].Push(line)
            ;     }
            ; }
            continue
        }

        section := fn["section"]
        if !sectionGroups.Has(section)
            sectionGroups[section] := []

        name := fn.Has("description") ? fn["description"] : fn_id
        hasSimilar := fn.Has("hasSimilarReturn") && fn["hasSimilarReturn"]

        if hasSimilar {
            entries := []
            for hkEntry in fn["hotkeys"] {
                key := IsObject(hkEntry) ? hkEntry["key"] : hkEntry
                entries.Push(hkexp(key))
            }
            argsText := fn.Has("args") ? JoinArgs(", ", fn["args"]*) : ""
            sectionGroups[section].Push(TextAlign(JoinArgs(" / ", entries*)) " → " name (argsText ? " (" argsText ")" :""))
        } else {
            for i, hkEntry in fn["hotkeys"] {
                key := IsObject(hkEntry) ? hkEntry["key"] : hkEntry
                cond := (IsObject(hkEntry) && hkEntry.Has("condition"))
                effectiveSection := cond ? "⚙️ HOTKEYS CONDITIONED BY SCRIPT STATUS" : section

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


GroupHotkeysBySection(script) {
    sectionGroups := Map()

    for fn_id, fn in script {
        if (fn_id = "Send") {
            if !sectionGroups.Has("Other")
                sectionGroups["Other"] := []
            for hk_id, hk in fn["hotkeys"] {
                display := IsObject(hk) ? hk[1] : hk
                sectionGroups["Other"].Push(TextAlign(hkexp(hk_id)) " → " hkexp(display))
            }
            continue
        }

        section := fn["section"]
        if !sectionGroups.Has(section)
            sectionGroups[section] := []

        name := fn.Has("description") ? fn["description"] : fn_id
        if fn.Has("args") {
            for i, args in fn["args"] {
                hk := fn["hotkeys"][i]
                hotkeyStr := IsObject(hk) ? hk[1] : hk
                argText := IsObject(args) ? JoinArgs(", ", args*) : args
                sectionGroups[section].Push(TextAlign(hkexp(hotkeyStr)) " → " name " (" argText ")")
            }
        } else {
            hk := fn["hotkeys"]
            hotkeyStr := IsObject(hk) ? hk[1] : hk
            sectionGroups[section].Push(TextAlign(hkexp(hotkeyStr)) " → " name)
        }
    }

    return sectionGroups
}

test_ShowScriptHotkeysUI(script_id := "#KeyModifier", hideTimer := 0, lineLimit := 10) {
    if !scripts.Has(script_id) {
        TrayTip "❌ Không tìm thấy script: " script_id
        return
    }

    script := scripts[script_id]
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

    for , name in preferredOrder {
        if sectionGroups.Has(name) {
            sections.Push({ title: name, lines: sectionGroups[name] })
            sectionGroups.Delete(name)
        }
    }
    for name, lines in sectionGroups {
        sections.Push({ title: name, lines: lines })
    }

    ShowHelp("🧩 Hotkeys cho script: " script_id, sections, hideTimer, lineLimit)
}

Save(inputJSON := hotkeysJSON, outputJSON := hotkeysJSON) {
    JSON.DumpFile(scripts, hotkeysJSON, 1)
    PrettifyJSON(hotkeysJSON, hotkeysJSON)
}

ShowAllScriptsFunctionsGUI() {
    myGui := gui("+AlwaysOnTop + Resize", "All Scripts Functions")
    myGui.SetFont("s10")

    checkboxes := Map() ; Map[script][fn_id] = checkbox control

    y := 10
    margin := 10
    lineHeight := 30
    sectionSpacing := 10

    for scriptName, script in scripts {
        ; Tạo GroupBox làm section
        myGui.Add("GroupBox", "x10 y" y " w250 h" (lineHeight * (script.Count + 1)), scriptName)
        y += 30

        checkboxes[scriptName] := Map()

        for fn_id, fn_data in script {
            if (fn_id = "Send")
                continue

            ; Thêm checkbox cho hàm
            cb := myGui.AddCheckbox("x30 y" y " w250 v" scriptName "_" fn_id, fn_id)
            checkboxes[scriptName][fn_id] := cb
            y += lineHeight
        }
        y += sectionSpacing
    }
    myGui.Show()
}

ShowScriptFunctionGUI(script) {
    if (!scripts.Has(script)) {
        MsgBox "⚠️ Script '" script "' not found in JSON."
        return
    }

    myGui := gui("+AlwaysOnTop", "Functions for " script)
    myGui.SetFont("s10")
    checkboxes := Map()

    ; Tạo checkbox cho mỗi function
    for fn_id, fn_data in scripts[script] {
        if (fn_id = "Send")
            continue

        label := fn_id
        cb := myGui.AddCheckbox("v" label, label)
        checkboxes[fn_id] := cb
    }
    myGui.Show("AutoSize Center")
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

BindingAll(citeria := "") {
    for script_id, script in scripts {
        BindingScript(script, citeria)
    }
}

BindingScript(script, citeria := "") {
    if (!scripts.has(script)) {
        TrayTip "⚠️ No hotkeys found for script: " script
        return false
    }
    for fn_id, fn in scripts[script] {
        if (fn_id = "Send") {
            for hk_id, hk in fn["hotkeys"] {
                hk := isObject(hk) ? hk[1] : hk
                AssignBoundHotkey(hk_id, "Send", citeria, hk)
            }
            continue
        }
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
        if (!fn.has("args")) {
            AssignBoundHotkey(fn["hotkeys"], fn_id, citeria)
            continue
        }
        else {
            for args_id, args in fn["args"] {
                if (IsObject(args)) {
                    AssignBoundHotkey(fn["hotkeys"][args_id], fn_id, citeria, args*)
                } else {
                    AssignBoundHotkey(fn["hotkeys"][args_id], fn_id, , args)
                }
            }
        }
    }
    return true
}

AssignBoundHotkey(Hotkey, Function, citeria := "", FnArgs*) {
    if (IsObject(Hotkey)) {
        HotIf citeria
        AssignHotkey(Hotkey[1], Function, FnArgs*)
        Hotif
    }
    else {
        AssignHotkey(Hotkey, Function, FnArgs*)
    }
}

AssignHotkey(Hotkey, Function, FnArgs*) {
    if (Hotkey = "" || Trim(Hotkey) = "") {
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

    try Hotkey(Hotkey, "Off")
    try {
        Hotkey(Hotkey, (*) => Function.Call(FnArgs*))
        return true
    } catch as e {
        we("❌ Lỗi khi gán hotkey `"" Hotkey "`" cho `"" Function.Name "`": " e.Message)
        return false
    }
}

GroupHotkeysByDisplayGroup(script) {
    groupMap := Map()

    for fn_id, fn in script {
        groupName := fn.Has("displayGroup") ? fn["displayGroup"] : ""
        if (groupName = "") {
            continue
        }

        entries := []
        if fn.Has("args") {
            for i, args in fn["args"] {
                hk := fn["hotkeys"][i]
                hotkeyStr := IsObject(hk) ? hk[1] : hk
                entries.Push(hkexp(hotkeyStr))
            }
        } else {
            hk := fn["hotkeys"]
            hotkeyStr := IsObject(hk) ? hk[1] : hk
            entries.Push(hkexp(hotkeyStr))
        }

        combinedHotkeys := JoinArgs(" / ", entries*)
        if !groupMap.Has(groupName)
            groupMap[groupName] := []

        groupMap[groupName].Push(combinedHotkeys " → " groupName)
    }

    return groupMap
}


ShowScriptHotkeysUI(script_id, hideTimer := 0, lineLimit := 10) {
    if !scripts.Has(script_id) {
        TrayTip "❌ Không tìm thấy script: " script_id
        return
    }

    lines := []
    script := scripts[script_id]

    for fn_id, fn in script {
        if fn_id = "Send" {
            for hk_id, hk in fn["hotkeys"] {
                display := IsObject(hk) ? hk[1] : hk
                lines.Push(TextAlign(hkexp(hk_id)) " → " hkexp(display))
            }
            continue
        }

        name := fn.Has("description") ? fn["description"] : fn_id
        if fn.Has("args") {
            for i, args in fn["args"] {
                hk := fn["hotkeys"][i]
                hotkeyStr := IsObject(hk) ? hk[1] : hk
                argText := IsObject(args) ? JoinArgs(", ", args*) : args
                lines.Push(TextAlign(hkexp(hotkeyStr)) " → " name " (" argText ")")
            }
        } else {
            hk := fn["hotkeys"]
            hotkeyStr := IsObject(hk) ? hk[1] : hk
            lines.Push(TextAlign(hkexp(hotkeyStr)) " → " name)
        }
    }

    sections := [{ title: "📄 Script: " script_id, lines: lines }]
    ShowHelp("🧩 Hotkeys cho script: " script_id, sections, hideTimer, lineLimit)
}

ShowAllHotkeysUI(hideTimer := 0, lineLimit := 5) {
    for script_id, script in scripts {
        ShowScriptHotkeysUI(script_id)
    }
}