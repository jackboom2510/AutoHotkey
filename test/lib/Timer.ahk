class TimerUI {
    static guiID := ""
    gui := unset
    name := "Timer"
    guiOpts := "+AlwaysOnTop +Resize -DPIScale -Caption +ToolWindow"
    xpos := 0
    ypos := 0
    guiWidth := 0
    guiHeight := 0
    defaultVals := ["30m", "45m", " pm", " am", "Pause", "Kill All"]
    currentTabIndex := 1
    transparency := 225

    okBtn := ""
    
    __New(options := "", args*) {
        if (TimerUI.guiID) {
            if WinExist("ahk_class AutoHotkeyGUI ahk_id " TimerUI.guiID) {
                return
            }
        }
        this.gui := Gui(this.guiOpts, this.name)
        TimerUI.guiID := this.gui.Hwnd
        this.gui.SetFont("s10", "Verdana")
        this.gui.BackColor := "E0FFFF"
        this.ParseOptions(options)
        this.ParseArgs(args*)
        this.SetupAll()
        this.Show()
        WinSetTransColor(this.gui.BackColor, this.name)
        WinSetTransparent(this.transparency, this.name)
        ; OnMessage(0x0100, ObjBindMethod(this, "ProcessKeyDownMsg"))
    }
    SetTimerUtils(timer) {
        this.gui.Destroy()
        if (timer = "kill" || timer = "k") {
            if (WinExist("Hourglass")) {
                ; WinKill("Hourglass")
                WinActivate("Hourglass")
                Sleep(500)
                Send "!{F4}"
                Sleep(500)
                Send "{Enter}"
            }
            return
        }
        if (timer = "kill all" || timer = "ka") {
            while (WinExist("Hourglass")) {
                ; WinKill("Hourglass")
                WinActivate("Hourglass")
                Sleep(500)
                Send "!{F4}"
                Sleep(500)
                Send "{Enter}"
                Sleep(1000)
            }
            TrayTip("Sucess Kill ALL the Hourglass", "🎆Success!", 0)
            return
        }
        if (timer = "" || timer = "p" || timer = "pause") {
            Send "!{Space}"
            SendText Format("timer {}", timer)
            Send("{Enter}")
            return
        }
        Send "!{Space}"
        Sleep(500)
        SendText Format("timer {}", timer)
        Sleep(500)
        Send("{Down}")
        Sleep(500)
        Send("{Enter}")
    }
    SetUpAll() {
        SetupControls
        SetupEvents
        SetupToolTips
        return
        SetupControls() {
            this.gui.AddText("Center w150", "Timer").SetFont("s12 italic bold c00aeff", "Verdana")
            this.timer := this.gui.AddEdit("w150 +Center", this.defaultVals[1])
            this.timer.SetFont("s12")
            this.okBtn := this.gui.AddButton("xm w75", "Ok")
            this.gui.AddButton("x+5 yp w75", "Cancel").OnEvent("Click", (*) => this.gui.Destroy())
        }
        SetupEvents() {
            this.gui.OnEvent("Escape", (*) => this.gui.Destroy())
            this.okBtn.OnEvent("Click", (*) => this.SetTimerUtils(this.timer.value))
        }
        SetupToolTips() {
        }
    }
    Show(options := "") {
        this.okBtn.Focus
        ShowOpts := "Restore "
        if (this.xpos != 0)
            ShowOpts .= Format("x{} ", this.xpos)
        if (this.ypos != 0)
            ShowOpts .= Format("y{} ", this.ypos)
        if (this.guiWidth != 0)
            ShowOpts .= Format("w{} ", this.guiWidth)
        if (this.guiHeight != 0)
            ShowOpts .= Format("h{} ", this.guiHeight)
        this.gui.Show(ShowOpts options)
    }
    ParseOptions(options) {
        flags := {
            w: "(\d+)",
            h: "(\d+)",
            x: "(\d+)",
            y: "(\d+)",
        }
        for flag, regex in flags.OwnProps() {
            while RegExMatch(options, flag . "\{" . regex . "\}", &Match) {
                switch flag {
                    case "w": this.guiWidth := Match[1]
                    case "h": this.guiHeight := Match[1]
                    case "x": this.xPos := Match[1]
                    case "y": this.yPos := Match[1]
                }
                break
            }
        }
        if RegExMatch(options, "\b(?!w|h|x|y)(\w+)\{([^}]+)\}", &match) {
            invalid_flag := match[1]
            invalid_value := match[2]
            TrayTip(":x: Invalid flag: `"" invalid_flag "`" with value: `"" invalid_value "`"",
                ":x: Invalid flag detected!", 3)
            return
        }
    }
    ParseArgs(args*) {
        for index, arg in args {
            if (arg ~= "^p\{(.+)\}(.+)$") {
                key := RegExMatch(arg, "^p\{(.+)\}(.+)$", &Match)
                if (key) {
                    this.%Match[1]% := Match[2]
                }
            } else {
                TrayTip ":x: Invalid argument format in args."
                OutputDebug ":x: Invalid argument format in args: " arg
            }
        }
    }
    ProcessKeyDownMsg(wPARAM, lPARAM, msg, hwnd) {
        if (msg != 0x0100) {
            return 1
        }
        if (wPARAM = 0x0D) {
            if (hwnd = this.timer.hwnd) {
                this.SetTimerUtils(this.timer.value)
                return 0
            }
        }
        else if (wPARAM = 0x09) {
            if (hwnd = this.timer.hwnd) {
                if (GetKeyState("Shift", "P")) {
                    ; Shift+Tab: Quay về chỉ mục trước đó
                    this.currentTabIndex := this.currentTabIndex - 1
                    if (this.currentTabIndex < 1) {
                        this.currentTabIndex := this.defaultVals.Length
                    }
                } else {
                    ; Tăng chỉ mục, nếu vượt quá kích thước mảng thì quay lại 1
                    this.currentTabIndex := this.currentTabIndex + 1
                    if (this.currentTabIndex > this.defaultVals.Length) {
                        this.currentTabIndex := 1
                    }
                    this.timer.Value := this.defaultVals[this.currentTabIndex]
                    this.timer.Focus() ; Đảm bảo focus
                    Send "{Home}"
                }
                return 0
            }
        }
        return 1
    }
}