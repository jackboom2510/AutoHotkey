#Requires AutoHotkey v2.0.18+
#SingleInstance Force
CoordMode "Mouse", "Screen"
Persistent
endl := '`n'

#Include <HelpGui>

class TrayMenuManager {
    isPaused := false
    isSuspended := false
    scriptName := ""

    __New(scriptName := "") {
        this.scriptName := scriptName
        this.Init()
        this.ShowHelp()
    }

    Init() {
        tray := A_TrayMenu
        tray.Delete()

        tray.Add("Help", (*) => this.ShowHelp())
        tray.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
        tray.Add()
        tray.Add("Reload Script", (*) => Reload())
        tray.Add("Edit Script", (*) => Edit())
        tray.Add()
        tray.Add("Suspend Hotkeys", (*) => this.ToggleSuspend())
        tray.Add("Pause Script", (*) => this.TogglePause())
        tray.Add("Exit", (*) => ExitApp())

        tray.Default := "Help"
        tray.ClickCount := 1

        this.UpdateChecks()
    }

    ToggleSuspend() {
        Suspend()
        this.isSuspended := !this.isSuspended
        this.UpdateChecks()
    }

    TogglePause() {
        Pause()
        this.isPaused := !this.isPaused
        this.UpdateChecks()
    }

    UpdateChecks() {
        tray := A_TrayMenu
        if this.isSuspended
            tray.Check("Suspend Hotkeys")
        else
            tray.Uncheck("Suspend Hotkeys")

        if this.isPaused
            tray.Check("Pause Script")
        else
            tray.Uncheck("Pause Script")
    }

    ShowHelp() {
        ; Doing something here
    }
}