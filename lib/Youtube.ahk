_UI

class _UI {
    gui := unset
    guiID := ''
    name := 'UI'
    guiOpts := '+AlwaysOnTop +Resize -DPIScale -Caption'

    guiPos := {
        x: 0,
        y: 0,
        w: 0,
        h: 0
    }

    transparency := {
        value: 225,
        min: 120,
        max: 255,
        step: 15
    }

    __New(options := '', args*) {
        if (this.guiID && WinExist('ahk_class AutoHotkeyGUI ahk_id ' this.guiID)) {
            return
        }
        this.gui := Gui(this.guiOpts, this.name)
        this.guiID := this.gui.Hwnd
        this.gui.SetFont('s10', 'Verdana')
        this.gui.BackColor := 'E0FFFF'

        this.SetupAll()
        this.ParseOptions(options)
        this.ParseArgs(args*)

        this.Show()
        WinSetTransColor(this.gui.BackColor, this.name)
        WinSetTransparent(this.transparency.value, this.name)
        OnMessage(0x0200, On_WM_MOUSEMOVE)
        OnMessage(0x4E, On_WM_NOTIFY)
        On_WM_MOUSEMOVE(wParam, lParam, msg, Hwnd) {
            PrevHwnd := 0
            if (Hwnd != PrevHwnd) {
                Text := ''
                SetTimer(ToolTip)
                CurrControl := GuiCtrlFromHwnd(Hwnd)
                if CurrControl {
                    if !CurrControl.HasProp('ToolTip')
                        return
                    Text := CurrControl.ToolTip
                    ToolTip(Text)
                }
                PrevHwnd := Hwnd
            }
        }
        On_WM_NOTIFY(wParam, lParam, Msg, hWnd) {
            UDN_DELTAPOS := -722
            is64Bit := (A_PtrSize = 8)

            NMUPDOWN := Buffer(is64Bit ? 40 : 24, 0)
            DllCall('RtlMoveMemory', 'Ptr', NMUPDOWN.Ptr, 'Ptr', lParam, 'UPtr', NMUPDOWN.Size)

            hwndFrom := NumGet(NMUPDOWN, 0, 'UPtr')
            code := NumGet(NMUPDOWN, is64Bit ? 16 : 8, 'Int')
            delta := NumGet(NMUPDOWN, is64Bit ? 28 : 16, 'Int')

            if (hwndFrom = this.transparency.valueUpDown.hwnd && code = UDN_DELTAPOS) {
                newVal := this.transparency.valueUpDown.Value + delta * this.transparency.value.step
                newVal := Min(Max(newVal, this.transparency.value.min), this.transparency.value.max)
                this.transparency.valueUpDown.Value := newVal
                this.transparency.value := newVal
                WinSetTransparent this.transparency.value, this.name
                return true
            }
        }
    }
    SetUpAll() {
        SetupControls
        SetupEvents
        SetupToolTips
        return
        SetupControls() {
            ; this.gui.AddEdit('w60 +Right').ToolTip := 'Adjust ' this.name ''s transparency (' this.transparency.value.min '–' this.transparency.value.max ').'
            ; this.transparency.valueUpDown := this.gui.AddUpDown('Range' this.transparency.value.min '-' this.transparency.value.max,
            ;     this.transparency.value)
        }
        SetupEvents() {

        }
        SetupToolTips() {
        }
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
            TrayTip(':x: Invalid flag: `'' invalid_flag '`' with value: `'' invalid_value '`'',
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


}


Esc:: ExitApp()