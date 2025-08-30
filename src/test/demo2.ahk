MyClock := ClockOverlay("x{1} y{1} w{150} h{100}")

class ClockOverlay {
    gui := unset
    guiID := ''
    name := 'ClockOverlay'
    guiOpts := '-Caption +AlwaysOnTop +LastFound +ToolWindow'
    TimeFormat := "hh:mm:ss"
    __New(options := '', args*) {
        if (this.guiID && WinExist('ahk_class AutoHotkeyGUI ahk_id ' this.guiID)) {
            return
        }
        this.gui := Gui(this.guiOpts, this.name)
        this.guiID := this.gui.Hwnd
        this.gui.SetFont('s20', '')
        this.gui.BackColor := 'E0FFFF'
        this.guiPos := {
            x: 0,
            y: 0,
            w: 600,
            h: 300
        }
        this.transparency := {
            value: 225,
            min: 120,
            max: 255,
            step: 15
        }

        this.ParseOptions(options)
        this.ParseArgs(args*)
        this.clock := this.gui.AddEdit("+ReadOnly +Disabled")
        this.UpdateClock()

        this.Show()
        WinSetTransColor(this.gui.BackColor, this.name)
        WinSetTransparent(this.transparency.value, this.name)
    }
    ParseOptions(options) {
        flags := {
            w: '(\d+)',
            h: '(\d+)',
            x: '(\d+)',
            y: '(\d+)',
        }
        for flag, regex in flags.OwnProps() {
            while RegExMatch(options, flag . '\{' . regex . '}', &Match) {
                switch flag {
                    case 'w': this.guiPos.w := Match[1]
                    case 'h': this.guiPos.h := Match[1]
                    case 'x': this.xPos := Match[1]
                    case 'y': this.yPos := Match[1]
                }
                break
            }
        }
        if RegExMatch(options, '\b(?!w|h|x|y)(\w+)\{([^}]+)}', &match) {
            invalid_flag := match[1]
            invalid_value := match[2]
            TrayTip(':x: Invalid flag: "' invalid_flag '" with value: "' invalid_value '"',
                ':x: Invalid flag detected!', 3)
            return
        }
    }
    ParseArgs(args*) {
        for index, arg in args {
            if (arg ~= '^p\{(.+)}(.+)$') {
                key := RegExMatch(arg, '^p\{(.+)}(.+)$', &Match)
                if (key) {
                    this.%Match[1]% := Match[2]
                }
            } else {
                TrayTip ':x: Invalid argument format in args.'
                OutputDebug ':x: Invalid argument format in args: ' arg
            }
        }
    }
    Show(options := '') {
        ShowOpts := 'Restore '
        if (this.guiPos.x != 0)
            ShowOpts .= Format('x{} ', this.guiPos.x)
        if (this.guiPos.y != 0)
            ShowOpts .= Format('y{} ', this.guiPos.y)
        if (this.guiPos.w != 0)
            ShowOpts .= Format('w{} ', this.guiPos.w)
        if (this.guiPos.h != 0)
            ShowOpts .= Format('h{} ', this.guiPos.h)
        this.gui.Show(ShowOpts options)
    }
    Toggle() {
        if !WinExist('ahk_id ' this.gui.hwnd)
            this.Show()
        else
            this.gui.Hide()
    }
    UpdateClock() {
        this.clock.Value := FormatTime(A_Now, this.TimeFormat)
        SetTimer((*) => this.UpdateClock(), 1000)
    }
}
