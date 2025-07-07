; HelpGui.ahk - Thư viện hiển thị GUI trợ giúp phím tắt
global isPaused := false
global isSuspended := false

ShowHelp(title := "🧩 Script Hotkey Help", sections := [], hideTimer := 0, lineLimit := 4) {
    static helpGui := ""

    if IsObject(helpGui) {
        helpGui.Show()
        return
    }

    helpGui := Gui("+AlwaysOnTop +Resize -Caption", title)
    helpGui.MarginX := 20
    helpGui.MarginY := 10
    helpGui.SetFont("s11 bold cBlue", "Segoe UI")
    
    if (title != "") {
        helpGui.AddText(, title)
    }

    for section in sections {
        if (section.HasProp("lines")) {
            AddSectionFromLines(helpGui, section.title, section.lines, lineLimit)
        } else {
            AddSection(helpGui, section.title, section.content, lineLimit)
        }
    }

    helpGui.AddButton("Default w100", "Đóng").OnEvent("Click", (*) => helpGui.Hide())
    helpGui.Show()
    if(hideTimer != 0)
        SetTimer(() => helpGui.Hide(), -hideTimer*1000)
}

AddSection(gui, title, content, lineLimit) {
    if (title != "") {
        gui.SetFont("s10 bold cGreen", "Segoe UI")
        gui.AddText("y+10", title)
    }

    gui.SetFont("s10 cBlack", "Consolas")
    content := Trim(content, "`r`n")
    
    ; Split nội dung thành các dòng
    lines := StrSplit(content, "`n")
    lineCount := lines.Length

    ; Nếu số dòng vượt quá giới hạn, cho phép cuộn dọc
    if (lineCount > lineLimit) {
        ; Thêm vùng cuộn (scrollable area) cho nội dung
        gui.AddText("y+10", "Xem tiếp")
        gui.AddEdit(Format("w600 h150 ReadOnly -Wrap -VScroll"), StrJoin("`n", lines))  ; h150 là chiều cao, có thể điều chỉnh
    } else {
        gui.AddEdit(Format("w600 r{} ReadOnly -Wrap", lineCount), content)
    }
}

AddSectionFromLines(gui, title, linesArray, lineLimit) {
    content := StrJoin("`n", linesArray*)
    AddSection(gui, title, content, lineLimit)
}

StrJoin(sep, args*) {
    out := ""
    for i, v in args {
        if args.Length {
            out .= (i > 1 ? sep : "") . StrJoin(sep, v*)
        } else {
            out .= (i > 1 ? sep : "") . v
        }
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