#Requires AutoHotkey v2.0+
#Include <ClickTracker>
#Include <HelpGui>
#Include <KeyBinding>
#Include <Log>
#SingleInstance Force
Persistent()
CoordMode "Mouse", "Client"
;@Ahk2Exe-SetMainIcon click.ico

script := "#ClickTracker"
ClickTracker_Hotkeys := BindingScript(script)

TrayMenuManager(script)

; ClickTracker_InitTrayMenu()
; ClickTracker_ShowHelpUI(5)

; ClickTracker_InitTrayMenu() {
;     A_TrayMenu.Delete()
;     A_TrayMenu.Add("Help", (*) => ClickTracker_ShowHelpUI())
;     A_TrayMenu.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
;     A_TrayMenu.Add()
;     A_TrayMenu.Add("Reload Script", (*) => Reload())
;     A_TrayMenu.Add("Edit Script", (*) => Edit())
;     A_TrayMenu.Add()
;     A_TrayMenu.Add("Suspend Hotkeys", (*) => ToggleSuspend())
;     A_TrayMenu.Add("Pause Script", (*) => TogglePause())
;     A_TrayMenu.Add("Show/Hide", (*) => ClickTracker.Toggle())
;     A_TrayMenu.Add("Exit", (*) => ExitApp())

;     A_TrayMenu.Default := "Show/Hide"
;     A_TrayMenu.ClickCount := 1
; }

; ClickTracker_ShowHelpUI(hideTimer := 0) {
;     sections := [{
;         title: "",
;         lines: [
;             hkexp(hotkeys[script]['ClickTracker.Track']["hotkeys"][1]) "`t→ Theo dõi một lần nhấp chuột thủ công",
;             hkexp(hotkeys[script]['ClickTracker.ToggleTracking']["hotkeys"][1]) "`t→ Bắt đầu/Dừng theo dõi nhấp chuột",
;         ]
;     },]
;     ShowHelp("🧩 ClickTracker Script Hotkey Help", sections, hideTimer)
; }
