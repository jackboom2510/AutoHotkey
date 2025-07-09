global isPaused := false
global isSuspended := false
ShowHelp(title := "🧩 Script Hotkey Help", sections := [], hideTimer := 0, lineLimit := 0) {
    static helpGUI := ""

    if IsObject(helpGUI) {
        helpGUI.Show()
        return
    }

    helpGUI := Gui("+AlwaysOnTop +Resize -Caption", title)
    helpGUI.MarginX := 20
    helpGUI.MarginY := 10
    helpGUI.SetFont("s11 bold cBlue", "Segoe UI")

    if (title != "") {
        helpGUI.AddText(, title)
    }

    for section in sections {
        if (section.HasProp("lines")) {
            AddSectionFromLines(helpGUI, section.title, section.lines, lineLimit)
        } else {
            AddSection(helpGUI, section.title, section.content, lineLimit)
        }
    }

    helpGUI.AddButton("Default w100", "Đóng").OnEvent("Click", (*) => helpGUI.Hide())
    helpGUI.Show()
    if (hideTimer != 0)
        SetTimer(() => helpGUI.Hide(), -hideTimer * 1000)
}

AddSection(gui, title, content, lineLimit := 0) {
    if (title != "") {
        gui.SetFont("s10 bold cGreen", "Segoe UI")
        gui.AddText("y+10", title)
    }

    gui.SetFont("s10 cBlack", "Consolas")
    content := Trim(content, "`r`n")
    if (lineLimit > 0)
        lineCount := Min(lineLimit, StrSplit(content, "`n").Length)
    else
        lineCount := StrSplit(content, "`n").Length
    gui.AddEdit(Format("w600 r{} ReadOnly -Wrap", lineCount), content)
}

AddSectionFromLines(gui, title, linesArray, lineLimit := 0) {
    content := StrJoin("`n", linesArray*)
    AddSection(gui, title, content, lineLimit)
}

StrJoin(sep, args*) {
    out := ""
    for i, v in args {
        out .= (i > 1 ? sep : "") . v
    }
    return out
}

ToggleSuspend() {
    global isSuspended
    Suspend()
    isSuspended := !isSuspended
    UpdateTrayChecks()
}

TogglePause() {
    global isPaused
    Pause()
    isPaused := !isPaused
    UpdateTrayChecks()
}

UpdateTrayChecks() {
    global isPaused, isSuspended
    if isSuspended
        A_TrayMenu.Check("Suspend Hotkeys")
    else
        A_TrayMenu.Uncheck("Suspend Hotkeys")

    if isPaused
        A_TrayMenu.Check("Pause Script")
    else
        A_TrayMenu.Uncheck("Pause Script")
}
