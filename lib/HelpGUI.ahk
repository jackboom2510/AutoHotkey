#Include <Log>

class HelpGui {
    __New(title := "🧩 Script Hotkey Help", sections := [], hideTimer := 0, lineLimit := 0) {
        this.gui := Gui("+AlwaysOnTop +Resize -DPIScale", title)
        this.gui.MarginX := 20
        this.gui.MarginY := 10
        this.gui.SetFont("s11 bold cBlue", "Segoe UI")

        if (title != "") {
            this.gui.AddText(, title)
        }

        for section in sections {
            if (section.HasProp("lines")) {
                this.AddSectionFromLines(section.title, section.lines, lineLimit)
            } else {
                this.AddSection(section.title, section.content, lineLimit)
            }
        }

        this.gui.AddButton("w100", "Đóng").OnEvent("Click", (*) => this.gui.Hide())

        if (hideTimer != 0) {
            SetTimer(this.gui.Hide.Bind(this.gui), -hideTimer * 1000)
        }
    }

    Show() {
        this.gui.Show()
    }

    AddSection(title, content, lineLimit := 5) {
        if (title != "") {
            this.gui.SetFont("s10 bold cGreen", "Segoe UI")
            this.gui.AddText("y+10", title)
        }

        this.gui.SetFont("s10 cBlack", "Consolas")
        content := Trim(content, "`r`n")
        if (lineLimit > 0)
            lineCount := Min(lineLimit, StrSplit(content, "`n").Length)
        else
            lineCount := StrSplit(content, "`n").Length
        this.gui.AddEdit("w800 ReadOnly -Wrap r" lineCount, content)
    }

    AddSectionFromLines(title, linesArray, lineLimit := 5) {
        linesArray := SortStringArrayByLength(linesArray)
        content := _Format(linesArray, 0, "o")
        this.AddSection(title, content, lineLimit)
    }
}

ShowHelp(title := "🧩 Script Hotkey Help", sections := [], hideTimer := 0, lineLimit := 0) {
    help := HelpGui(title, sections, hideTimer, lineLimit)
    help.Show()
    return help.gui  ; Trả về instance GUI để sử dụng nếu cần
}