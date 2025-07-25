#include <Log>
class HelpGui {
    guiOpts := "+AlwaysOnTop +Resize -DPIScale -Caption"
    __New(title := "🧩 Script Hotkey Help", sections := [], hideTimer := 0, lineLimit := 4) {
        this.gui := Gui(this.guiOpts, title)
        this.gui.SetFont("s10 bold", "Consolas")
        this.gui.MarginX := 20
        this.gui.MarginY := 15
        this.SectionT := []
        this.LSection := []
        this.RSection := []
        if (title != "") {
            this.gui.AddText("h30", TextAlign(title, [110], 'r')).SetFont("s12 bold cBlue", "Segoe UI") ; Center title
        }
        currentY := 0
        column1X := 20
        column2X := 420
        columnWidth := 450
        fullWidth := 920

        for idx, section in sections {
            {
                sectionTitle := section.HasOwnProp("title") ? TextAlign(section.title, [100], 'r') : ""
                unconditionalLines := section.HasOwnProp("unconditionalLines") ? section.unconditionalLines : ""
                conditionalLines := section.HasOwnProp("conditionalLines") ? section.conditionalLines : ""
                currentYLeft := 0
                currentYRight := 0
                contentLeft := Trim(_Format('`n', 0, 'plain', unconditionalLines), "`r`n")
                contentRight := Trim(_Format('`n', 0, 'plain', conditionalLines), "`r`n")
                lineCountLeft := StrSplit(contentLeft, "`n").Length
                lineCountRight := StrSplit(contentRight, "`n").Length
                if (lineLimit > 0)
                    lineCount := Min(lineLimit, Max(lineCountLeft, lineCountRight))
                else
                    linCount := Max(lineCountLeft, lineCountRight)
            }
            SectionTOpt := "xm y+10 h30 ReadOnly"
            this.SectionT.Push(this.gui.AddText(SectionTOpt, sectionTitle))
            this.SectionT[this.SectionT.Length].SetFont("s11 bold cGreen", "Segoe UI")
            this.gui.AddText("xm yp")

            if (contentLeft != "") {
                if (contentRight = "")
                    LSectionOpt := "w" fullWidth
                else
                    LSectionOpt := "w" columnWidth
                this.LSection.Push(this.gui.AddEdit(LSectionOpt " -Wrap ReadOnly r" lineCount, contentLeft))
                this.LSection[this.LSection.Length].SetFont("s10 cBlack", "Consolas")
            }

            if (contentRight != "") {
                if (contentRight = "")
                    RSectionOpt := "w" fullWidth
                else
                    RSectionOpt := "yp w" columnWidth
                this.RSection.Push(this.gui.AddEdit(RSectionOpt " -Wrap ReadOnly r" lineCount, contentRight))
                this.RSection[this.RSection.Length].SetFont("s10 c36007c", "Consolas")
            }
        }

        this.CloseBtn := this.gui.AddButton("xm y+20 w100", "Đóng")
        this.CloseBtn.SetFont("s10", "Segoe UI")
        this.CloseBtn.OnEvent("Click", (*) => this.gui.Hide())
        this.CloseBtn.Focus

        if (hideTimer != 0) {
            SetTimer(this.gui.Hide.Bind(this.gui), -hideTimer * 1000)
        }
    }
    Toggle() {
        if WinExist('ahk_id ' this.gui.hwnd)
            this.gui.Hide()
        else
            this.gui.Show()
        return
    }
}