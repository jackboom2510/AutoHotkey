class StatusOverlay {
    static instances := []
    static globalVisible := true
    gui := ""
    guiTitle := "Status Overlay"
    guiOpts := "+AlwaysOnTop -Caption +ToolWindow +E0x20"
    guiWidth := 18
    guiHeight := 24
    xPos := 0
    yPos := 0
    bgColor1 := "7c0080"
    bgColor2 := "Red"
    textColor1 := "White"
    textColor2 := "White"
    OnIcon := "✅"
    OffIcon := "⛔"
    iconRatio := 0.75
    isScriptEnabled := false
    statusTextControl := ""

    __New(guiTitle := this.guiTitle, options := "", args*) {
        this.guiTitle := guiTitle
        this.ParseOptions(options)
        this.ParseArgs(args*)
        this.Show()
        StatusOverlay.instances.Push(this)
    }
    Show() {
        if (this.gui) {
            this.gui.Destroy()
        }
        this.gui := Gui(this.guiOpts)
        this.gui.BackColor := this.isScriptEnabled ? this.bgColor1 : this.bgColor2
        this.statusTextControl := this.gui.AddText("+Center w" this.guiWidth " h" this.guiHeight " ",
            this.isScriptEnabled ? this.OnIcon : this.OffIcon)
        this.statusTextControl.SetFont("s" Floor(Min(this.guiWidth, this.guiHeight) * this.iconRatio) " Bold c" (this.isScriptEnabled ?
            this.textColor1 : this.textColor2), "Cascadia Code")
        this.gui.Show("x" this.xPos " y" this.yPos " NoActivate")
    }
    ; ParseConfig(options := "", args*) {
    ;     flags := Map(
    ;         "w", 1, "h", 1,
    ;         "x", 1, "y", 1,
    ;         "rx", 1, "ry", 1,
    ;         "bg1", 1, "bg2", 1,
    ;         "tx1", 1, "tx2", 1
    ;     )

    ;     _parseOptions(options, flags)
    ;     _parseArgs(args, flags)
    ;     _checkConflict()

    ;     ; ================= HÀM CON =================
    ;     _parseOptions(options, flags) {
    ;         if !options
    ;             return
    ;         for flag in flags {
    ;             if RegExMatch(options, flag "(?P<val>-?\w+)\b", &m)
    ;                 this.%flag% := m.val
    ;         }

    ;         ; Tìm flag không hợp lệ
    ;         invalid := []
    ;         while RegExMatch(options, "(?P<flag>\w+)\{(?P<value>[^}]+)\}", &m, A_Index = 1 ? 1 : m.Pos + 1) {
    ;             if !flags.Has(m.flag)
    ;                 invalid.Push(m.flag)
    ;         }
    ;         if invalid.Length
    ;             TrayTip(":x: Invalid option flag(s)", " -> " JoinArgs(",", invalid), 3)
    ;     }

    ;     _parseArgs(args, flags) {
    ;         if !args.Length
    ;             return
    ;         invalid := []
    ;         for each, arg in args {
    ;             if RegExMatch(arg, "^p\{(?P<key>.+?)\}(?P<val>.+)$", &m) {
    ;                 if flags.Has(m.key) {
    ;                     this.%m.key% := m.val ; Ưu tiên args > options
    ;                 } else {
    ;                     invalid.Push(m.key)
    ;                 }
    ;             } else {
    ;                 TrayTip(":x: Invalid arg format", " -> " arg, 3)
    ;             }
    ;         }
    ;         if invalid.Length
    ;             TrayTip(":x: Invalid args flag(s)", " -> " JoinArgs(",", invalid), 3)
    ;     }

    ;     _checkConflict() {
    ;         if (this.HasProp("x") && this.HasProp("rx"))
    ;             TrayTip(":x: Conflict!", "Cannot use both x and rx", 3)
    ;         if (this.HasProp("y") && this.HasProp("ry"))
    ;             TrayTip(":x: Conflict!", "Cannot use both y and ry", 3)
    ;     }
    ;     ; ======== TÍNH RECT ========
    ;     GetRect(monitor_idx := 1, defaultW := 100, defaultH := 50) {
    ;         MonitorGet(monitor_idx, &l, &t, &r, &b)
    ;         w := this.HasProp("w") ? this.w : defaultW
    ;         h := this.HasProp("h") ? this.h : defaultH
    ;         if (this.HasProp("x")) {
    ;             x := this.x
    ;         }
    ;         else if (this.HasProp("rx")) {
    ;             x := r - this.rx - w
    ;         }
    ;         else
    ;             x := l
    ;         if this.HasProp("y") {
    ;             y := this.y
    ;         }
    ;         else if this.HasProp("ry") {
    ;             y := b - this.ry - h
    ;         }
    ;         else
    ;             y := t
    ;         return { x: x, y: y, w: w, h: h }
    ;     }
    ; }
    ParseOptions(options) {
        flags := {
            w: "(-?\d+)\b",
            h: "(-?\d+)\b",
            x: "(-?\d+)\b",
            y: "(-?\d+)\b",
            bg1: "(\w+)\b",
            bg2: "(\w+)\b",
            tx1: "(\w+)\b",
            tx2: "(\w+)\b"
        }
        for flag, regex in flags.OwnProps() {
            while RegExMatch(options, flag regex, &Match) {

                switch flag {
                    case "w": this.guiWidth := Match[1]
                    case "h": this.guiHeight := Match[1]
                    case "x": this.xPos := Match[1]
                    case "y": this.yPos := Match[1]
                    case "bg1": this.bgColor1 := Match[1]
                    case "bg2": this.bgColor2 := Match[1]
                    case "tx1": this.textColor1 := Match[1]
                    case "tx2": this.textColor2 := Match[1]
                }
                break
            }
        }
        if RegExMatch(options, "\b(?!w|h|x|y|bg1|bg2|tx1|tx2)(\w+)\{([^}]+)\}", &match) {
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
    ToggleVisibility() {
        if (WinExist("ahk_id " this.gui.hwnd)) {
            this.gui.Hide
        } else {
            this.gui.Show()
        }
    }
    ToggleScript(toState := "") {
        if (toState = "")
            this.isScriptEnabled := !this.isScriptEnabled
        else
            this.isScriptEnabled := toState
        if (this.gui) {
            this.gui.BackColor := this.isScriptEnabled ? this.bgColor1 : this.bgColor2
            this.statusTextControl.SetFont("c" (this.isScriptEnabled ? this.textColor1 : this.textColor2))
            this.statusTextControl.Value := this.isScriptEnabled ? this.OnIcon : this.OffIcon
        }
        return this.isScriptEnabled
    }
    On_WM_SIZE(wPARAM, lPARAM, msg, hwnd) {
        if (hwnd != this.gui.hwnd)
            return
        newWidth := lPARAM & 0xFFFF
        newHeight := lPARAM >> 16
        newFontSize := Floor(Min(newWidth, newHeight) * this.iconRatio)
        if (newFontSize < 10) {
            newFontSize := 10
        }
        this.statusTextControl.SetFont("s" newFontSize, "Segoe UI Emoji")
        this.statusTextControl.Move(, , newWidth, newHeight)
        this.statusTextControl.Opt("Center")
    }
    On_WM_SIZING(wPARAM, lPARAM, msg, hwnd) {
        if (hwnd != this.gui.Hwnd)
            return

        rect := {
            Left: NumGet(lPARAM, 0, "Int"),
            Top: NumGet(lPARAM, 4, "Int"),
            Right: NumGet(lPARAM, 8, "Int"),
            Bottom: NumGet(lPARAM, 12, "Int")
        }

        currentWidth := rect.Right - rect.Left
        currentHeight := rect.Bottom - rect.Top
        this.gui.GetClientPos(, , &currentClientWidth, &currentClientHeight)
        aspectRatio := 1.0
        originalLeft := rect.Left
        originalTop := rect.Top
        originalRight := rect.Right
        originalBottom := rect.Bottom
        switch wPARAM {
            case 1:
                newWidth := currentWidth
                newHeight := Floor(newWidth / aspectRatio)
                rect.Top := originalBottom - newHeight
            case 2:
                newWidth := currentWidth
                newHeight := Floor(newWidth / aspectRatio)
                rect.Bottom := originalTop + newHeight
            case 3:
                newHeight := currentHeight
                newWidth := Floor(newHeight * aspectRatio)
                rect.Left := originalRight - newWidth
            case 6:
                newHeight := currentHeight
                newWidth := Floor(newHeight * aspectRatio)
                rect.Right := originalLeft + newWidth
            case 4:
                deltaX := originalLeft - rect.Left
                deltaY := originalTop - rect.Top
                delta := Max(deltaX, deltaY)

                newWidth := currentWidth + delta
                newHeight := Floor(newWidth / aspectRatio)

                rect.Left := originalRight - newWidth
                rect.Top := originalBottom - newHeight

            case 5:
                deltaX := rect.Right - originalRight
                deltaY := originalTop - rect.Top
                delta := Max(deltaX, deltaY)

                newWidth := currentWidth + delta
                newHeight := Floor(newWidth / aspectRatio)

                rect.Right := originalLeft + newWidth
                rect.Top := originalBottom - newHeight

            case 7:
                deltaX := originalLeft - rect.Left
                deltaY := rect.Bottom - originalBottom
                delta := Max(deltaX, deltaY)

                newWidth := currentWidth + delta
                newHeight := Floor(newWidth / aspectRatio)

                rect.Left := originalRight - newWidth
                rect.Bottom := originalTop + newHeight

            case 8:
                deltaX := rect.Right - originalRight
                deltaY := rect.Bottom - originalBottom
                delta := Max(deltaX, deltaY)

                newWidth := currentWidth + delta
                newHeight := Floor(newWidth / aspectRatio)

                rect.Right := originalLeft + newWidth
                rect.Top := originalBottom - newHeight
        }
        MIN_SIZE := 50
        if (newWidth < MIN_SIZE) {
            newWidth := MIN_SIZE
            if (wPARAM = 1 || wPARAM = 4 || wPARAM = 7)
                rect.Left := originalRight - newWidth
            else
                rect.Right := originalLeft + newWidth
        }
        if (newHeight < MIN_SIZE) {
            newHeight := MIN_SIZE
            if (wPARAM = 3 || wPARAM = 4 || wPARAM = 5)
                rect.Top := originalBottom - newHeight
            else
                rect.Bottom := originalTop + newHeight
        }
        NumPut("Int", rect.Left, lPARAM, 0)
        NumPut("Int", rect.Top, lPARAM, 4)
        NumPut("Int", rect.Right, lPARAM, 8)
        NumPut("Int", rect.Bottom, lPARAM, 12)
        finalFontSize := Floor(Min(newWidth, newHeight) * this.iconRatio)
        if (finalFontSize < 10) {
            finalFontSize := 10
        }
        this.statusTextControl.SetFont("s" finalFontSize " Bold cWhite", "Segoe UI Emoji")
        this.statusTextControl.Move(0, 0, newWidth, newHeight)
        this.statusTextControl.Opt("+Center")

        return True
    }
    static ToggleAll(toState := "", exceptions := []) {
        for idx, exc in exceptions {
            if (exc is String)
                exceptions[idx] := %exceptions[idx]%
        }
        if (toState = "") {
            this.globalVisible := !this.globalVisible
        } else {
            this.globalVisible := toState
        }

        for inst in this.instances {
            skip := false
            for exc in exceptions {
                if (inst = exc) {
                    skip := true
                    break
                }
            }
            if (skip)
                continue
            if (this.globalVisible)
                inst.gui.Show()
            else
                inst.gui.Hide()
        }
    }
}
