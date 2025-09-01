; what := '', title := A_ScriptName, setupFlags := 't10 ra rb w', options := '', args*
class NotificationUI {
    gui := unset
    guiID := ''
    guiOpts := '+AlwaysOnTop +ToolWindow'
    defaultWidth := 500
    defaultFont := ['s12', 'Cascadia Code']
    defaultTitleFont := ['s14 bold cGreen', 'Cascadia Code']
    defaultBackgroundColor := 'E0FFFF'
    transparencyValue := 225
    charLimit := 50
    timeout := 10
    __New(what := '', title := A_ScriptName, setupFlags := 't10 ra rb s', options := '', args*) {
        if (this.guiID && WinExist('ahk_class AutoHotkeyGUI ahk_id ' this.guiID)) {
            return
        }
        if RegExMatch(setupFlags, '\bt(\d+(\.\d+)?)\b', &m)
            this.timeout := m[1]
        if (this.timeout != 0)
            this.guiOpts .= " -Caption"
        this.gui := Gui(this.guiOpts, title)
        this.guiID := this.gui.Hwnd
        this.gui.SetFont(this.defaultFont*)
        this.gui.BackColor := this.defaultBackgroundColor
        this.notificationTimer := this.timeout * 1000
        this.fullPromt := what
        wrappedText := this.WordWrap(what, this.charLimit)
        lines := StrSplit(wrappedText, '`n')
        lineCount := lines.Length
        autoHeight := lineCount * 20
        this.guiPos := {
            w: this.defaultWidth,
            h: autoHeight
        }
        if (RegExMatch(setupFlags, '\br?(b|before)\b')) {
            this.BeforeSetup()
            if (RegExMatch(setupFlags, '\br(b|before)\b'))
                NotificationUI.Prototype.DefineProp("BeforeSetup", { Call: (*) => {} })
        }
        if (title != "") {
            this.guiPos.h += 40
            this.title := this.gui.AddText(Format('Center w{} h25', this.guiPos.w - 50), title)
            this.title.SetFont(this.defaultTitleFont*)
        }
        this.content := this.gui.AddEdit(Format('+Wrap -VScroll w{}', this.guiPos.w - 25), wrappedText)
        this.guiPos.h += 30 ; Low Margin
        if (RegExMatch(setupFlags, '\br?(a|after)\b')) {
            this.AfterSetup()
            if (RegExMatch(setupFlags, '\br(a|after)\b'))
                NotificationUI.Prototype.DefineProp("AfterSetup", { Call: (*) => {} })
        }
        if (RegExMatch(setupFlags, '\b(s|sound)\b'))
            SoundPlay("D:\3. Downloads\Music\mixkit-positive-notification-951.wav")
        this.Show("NoActivate")
        WinSetTransColor(this.defaultBackgroundColor, title)
        WinSetTransparent(this.transparencyValue, title)
        SetTimer((*) => (this.gui.Destroy()), -this.notificationTimer)
        if (RegExMatch(setupFlags, '\b(w|wait)\b') && this.timeout != 0)
            Sleep(this.notificationTimer + 500)
    }
    BeforeSetup() {
    }
    AfterSetup() {
    }
    WordWrap(text, limit) {
        if (StrLen(text) - 1 < 2 * limit) {
            text := RegExReplace(text, "\n->", " ->")
        }
        pattern := '\n|[ \t]+|\S+'
        words := []
        pos := 1
        while pos := RegExMatch(text, pattern, &m, pos) {
            words.Push(m[0])
            pos += StrLen(m[0])
        }
        lines := []
        currentLine := ""
        for word in words {
            if (word = "`n") {
                lines.Push(currentLine)
                currentLine := ""
                continue
            }
            if (StrLen(word) > limit) {
                if (currentLine != "") {
                    lines.Push(currentLine)
                    currentLine := ""
                }
                while (StrLen(word) > limit) {
                    lines.Push(SubStr(word, 1, limit))
                    word := SubStr(word, limit + 1)
                }
                currentLine := word
                continue
            }
            if (StrLen(currentLine) + StrLen(word) > limit) {
                lines.Push(currentLine)
                currentLine := (RegExMatch(word, "^\s+$") ? "" : word)
            } else
                currentLine .= word
        }
        if (currentLine != "")
            lines.Push(currentLine)
        out := ""
        for i, line in lines
            out .= (i > 1 ? "`n" : "") . line
        return out
    }
    Show(options := '') {
        if (SysGet(80) > 1) {
            old_CoordMode := A_CoordModeMouse
            CoordMode 'mouse', 'screen'
            MouseGetPos(&mx, &my)
            monitorIdx := (mx >= 0 && mx <= A_ScreenWidth) ? 2 : 1
            MonitorGet(monitorIdx, , , &screenW, &screenH)
            if (A_IsCompiled && monitorIdx = 1) {
                this.guiPos.w *= 1.5
                this.guiPos.h *= 1.5
            }
            CoordMode 'mouse', old_CoordMode
        }
        else {
            screenW := A_ScreenWidth
            screenH := A_ScreenHeight
        }
        xPos := screenW - this.guiPos.w - 10
        yPos := screenH - this.guiPos.h - 50
        if (this.timeout = 0) {
            yPos -= 40
            xPos -= 20
        }
        ShowOpts := Format('x{} y{} w{} h{} ', xPos, yPos, this.guiPos.w, this.guiPos.h)
        this.gui.Show(ShowOpts options)
    }
}
