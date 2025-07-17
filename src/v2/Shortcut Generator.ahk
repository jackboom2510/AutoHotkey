#Include <ShortcutTool>
#Include <HelpGui>
#Include <KeyBinding>
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()

;@Ahk2Exe-SetMainIcon C:\Users\jackb\Documents\AutoHotkey\icon\internet.ico

; ====== Hotkeys ======

BindingScript("ShortcutGenerator")


; ====== Start ====
; ShortcutGen_InitTrayMenu()

; ShortcutGen_InitTrayMenu() {
;     A_TrayMenu.Delete()
;     A_TrayMenu.Add("Open File Location", (*) => Run("*open " A_ScriptDir))
;     A_TrayMenu.Add()
;     A_TrayMenu.Add("Reload Script", (*) => Reload())
;     A_TrayMenu.Add("Edit Script", (*) => Edit())
;     A_TrayMenu.Add("Open Script Location", (*) => Run("*open " A_ScriptDir))
;     A_TrayMenu.Add("Suspend Hotkeys", (*) => ToggleSuspend())
;     A_TrayMenu.Add("Pause Script", (*) => TogglePause())
; 	A_TrayMenu.Add("Show/Hide", (*) => ShortcutTool.Toggle())
;     A_TrayMenu.Add("Exit", (*) => ExitApp())

;     A_TrayMenu.Default := "Show/Hide"
; 	A_TrayMenu.ClickCount := 1
; }