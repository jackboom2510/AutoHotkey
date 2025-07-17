#Requires AutoHotkey v2.0+
#SingleInstance Force
Persistent()
CoordMode "Mouse", "Client"

#Include <ClickTracker>
#Include <KeyBinding>

;@Ahk2Exe-SetMainIcon click.ico

BindingScript()
A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowScriptHotkeysUI())