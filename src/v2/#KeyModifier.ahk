#Requires AutoHotkey v2.0+
#SingleInstance Force
Persistent()
; CoordMode "Mouse", "Window"
#Include <KeyBinding>
#Include <StatusOverlay>

#Include <KeyModifier>
#Include <ClickMacro>

overlay := StatusOverlay("Status Overlay", "bg1{Blue} bg2{Red}")
options := KeyBindingUI(["Button","Hotkeys", "xp-80 yp w75", (*) => ShowScriptHotkeysUI(), "Show Hotkeys"])

A_TrayMenu.Delete
A_TrayMenu.AddStandard()
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Toggle", (*) => options.Toggle())
A_TrayMenu.Insert("E&xit", "Hotkeys", (*) => ShowScriptHotkeysUI())
A_TrayMenu.Default := "Toggle"
A_TrayMenu.ClickCount := 1

GetScriptStatus(*) {
    return overlay.isScriptEnabled = true
}

GetOption4(*) {
    return options.Checkbox[4].Value = 1
}

HotIf GetOption4
BindingScript(, 2)
HotIf

#HotIf (options.Checkbox[3].Value)
+Space:: Send("_")
XButton1:: Send("{F10}")
XButton2:: Send("{F11}")
#HotIf

#Hotif (options.Checkbox[2].Value)
PgUp:: return
+PgUp:: return
^PgUp:: return
!PgUp:: return
#PgUp:: return
^+PgUp:: return
^!PgUp:: return
!+PgUp:: return
#+PgUp:: return
#^PgUp:: return
#!PgUp:: return
^!+PgUp:: return
^!#PgUp:: return
>^PgUp:: return

PgDn:: return
+PgDn:: return
^PgDn:: return
!PgDn:: return
#PgDn:: return
^+PgDn:: return
^!PgDn:: return
!+PgDn:: return
#+PgDn:: return
#^PgDn:: return
#!PgDn:: return
^!+PgDn:: return
^!#PgDn:: return
#HotIf 