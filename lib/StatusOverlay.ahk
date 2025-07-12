global isOverlayVisible := true
global isScriptEnabled := false
class StatusOverlay {
    guiTitle := "Status Overlay"
    guiWidth := 15
    guiHeight := 20
    xPos := 0
    yPos := 0
    bgColor1 := "Green"
    bgColor2 := "Red"

    __New(guiTitle := "Status Overlay", guiWidth := this.guiWidth, guiHeight := this.guiHeight, xPos := this.xPos, yPos :=
        this.yPos, bgColor1 :=
        this.bgColor1, bgColor2 :=
        this.bgColor2) {
        this.guiTitle := guiTitle
        this.guiWidth := guiWidth
        this.guiHeight := guiHeight
        this.xPos := xPos
        this.yPos := yPos
        this.bgColor1 := bgColor1
        this.Show()
    }

    Show() {
        global statusOverlayGui, isScriptEnabled
        if IsSet(statusOverlayGui)
            statusOverlayGui.Destroy()
        statusOverlayGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        statusOverlayGui.BackColor := isScriptEnabled ? this.bgColor1 : this.bgColor2
        statusOverlayGui.SetFont("s10 Bold cWhite", "Segoe UI Emoji")
        statusOverlayGui.Add("Text", "Center w" this.guiWidth " h" this.guiHeight " ", isScriptEnabled ?
            "✅" :
                "⛔")

        statusOverlayGui.Show("x" this.xPos " y" this.yPos " NoActivate")
    }
}

overlay := StatusOverlay()

GetScriptStatus(*) {
    return isScriptEnabled
}

ToggleScript() {
    global isScriptEnabled := !isScriptEnabled
    overlay.Show()
}

ToggleOverlayVisibility() {
    global statusOverlayGui, isOverlayVisible, isOverlayVisible := !isOverlayVisible
    if (isOverlayVisible) {
        overlay.Show()
    } else {
        if IsSet(statusOverlayGui)
            statusOverlayGui.Destroy()
    }
}
