class StatusOverlay {
    static _gui := ""
    guiTitle := "Status Overlay"
    guiOpts := "+AlwaysOnTop -Caption +ToolWindow"
    guiWidth := 15
    guiHeight := 20
    xPos := 0
    yPos := 0
    bgColor1 := "7c0080"
    bgColor2 := "Red"

    OnIcon := "✅"
    OffIcon := "⛔"
    iconRatio := 0.68

    isScriptEnabled := false

    static statusTextControl := ""
    __New(guiTitle := this.guiTitle, options := "", args*) {
        this.guiTitle := guiTitle
        this.ParseOptions(options)
        this.ParseArgs(args*)
        this.Show()
        OnMessage(0x0214, ObjBindMethod(this, "On_WM_SIZING"))
    }
    Show() {
        if (StatusOverlay._gui) {
            StatusOverlay._gui.Destroy()
        }
        StatusOverlay._gui := Gui(this.guiOpts)
        StatusOverlay._gui.BackColor := this.isScriptEnabled ? this.bgColor1 : this.bgColor2
        StatusOverlay.statusTextControl := StatusOverlay._gui.AddText("+Center w" this.guiWidth " h" this.guiHeight " ",
            this.isScriptEnabled ? this.OnIcon : this.OffIcon)
        StatusOverlay.statusTextControl.SetFont("s" Floor(Min(this.guiWidth, this.guiHeight) * this.iconRatio) " Bold cWhite",
        "Segoe UI Emoji")
        StatusOverlay._gui.Show("x" this.xPos " y" this.yPos " NoActivate")
    }
    ParseOptions(options) {
        flags := {
            w: "(\d+)",
            h: "(\d+)",
            x: "(\d+)",
            y: "(\d+)",
            bg1: "(\w+)",
            bg2: "(\w+)",
        }
        for flag, regex in flags.OwnProps() {
            while RegExMatch(options, flag . "\{" . regex . "\}", &Match) {
                switch flag {
                    case "w": this.guiWidth := Match[1]
                    case "h": this.guiHeight := Match[1]
                    case "x": this.xPos := Match[1]
                    case "y": this.yPos := Match[1]
                    case "bg1": this.bgColor1 := Match[1]
                    case "bg2": this.bgColor2 := Match[1]
                }
                break
            }
        }
        if RegExMatch(options, "\b(?!w|h|x|y|bg1|bg2)(\w+)\{([^}]+)\}", &match) {
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
        if (WinExist("ahk_id " StatusOverlay._gui.hwnd)) {
            StatusOverlay._gui.Hide
        } else {
            StatusOverlay._gui.Show()
        }
    }
    ToggleScript() {
        this.isScriptEnabled := !this.isScriptEnabled
        if (StatusOverlay._gui) {
            StatusOverlay._gui.BackColor := this.isScriptEnabled ? this.bgColor1 : this.bgColor2
            StatusOverlay.statusTextControl.Value := this.isScriptEnabled ? this.OnIcon : this.OffIcon
        }
    }
    On_WM_SIZE(wPARAM, lPARAM, msg, hwnd) {
        if (hwnd != StatusOverlay._gui.hwnd)
            return
        newWidth := lPARAM & 0xFFFF
        newHeight := lPARAM >> 16
        newFontSize := Floor(Min(newWidth, newHeight) * this.iconRatio)
        if (newFontSize < 10) {
            newFontSize := 10
        }
        StatusOverlay.statusTextControl.SetFont("s" newFontSize " Bold cWhite", "Segoe UI Emoji")
        StatusOverlay.statusTextControl.Move(, , newWidth, newHeight)
        StatusOverlay.statusTextControl.Opt("Center")
    }
    On_WM_SIZING(wPARAM, lPARAM, msg, hwnd) {
        if (hwnd != StatusOverlay._gui.Hwnd)
            return

        rect := {
            Left: NumGet(lPARAM, 0, "Int"),
            Top: NumGet(lPARAM, 4, "Int"),
            Right: NumGet(lPARAM, 8, "Int"),
            Bottom: NumGet(lPARAM, 12, "Int")
        }

        currentWidth := rect.Right - rect.Left
        currentHeight := rect.Bottom - rect.Top
        StatusOverlay._gui.GetClientPos(, , &currentClientWidth, &currentClientHeight)
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
        StatusOverlay.statusTextControl.SetFont("s" finalFontSize " Bold cWhite", "Segoe UI Emoji")
        StatusOverlay.statusTextControl.Move(0, 0, newWidth, newHeight)
        StatusOverlay.statusTextControl.Opt("+Center")

        return True
    }
}

