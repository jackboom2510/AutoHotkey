#Requires AutoHotkey v2.1-alpha.1+
#SingleInstance Force
Persistent()

#Include <KeyBinding>
#Include <StatusOverlay>

#Include <KeyModifier>
#Include <ClickMacro>
#Include <Timer> 
; #Include ChangeLLayout.ahk
; "ChangeLang": {
;     "description": "Switch between Language Layout: Vietnamese/English.",
;     "hotkeys": [{ "key": "!z" }],
;     "section": "🛠️ SYSTEM CONFIGURATIONS"
; },

overlay := StatusOverlay(, "bg1{Green} bg2{Red}")
options := KeyBindingUI(["Button", "Hotkeys", "xp-80 yp w75", (*) => ShowHotkeys(, , 4), "Show Hotkeys"])
SetTimer (*) => options.Hide(), -3000   

{
    A_TrayMenu.Delete()
    A_TrayMenu.AddStandard()
    if (A_IsCompiled) {
        A_TrayMenu.Insert("&Suspend Hotkeys", "Reload Script", (*) => Reload())
        A_TrayMenu.Insert("&Suspend Hotkeys", "Edit Script", (*) => Run("*edit " "C:\Users\jackb\Documents\AutoHotkey\src\v2\#KeyModifier.ahk"
        ))
        A_TrayMenu.Insert("&Suspend Hotkeys")   
    }
    A_TrayMenu.Insert("E&xit")
    A_TrayMenu.Insert("E&xit", "Open File Location", (*) => Run("*open " "C:\Users\jackb\Documents\AutoHotkey\src\v2\"))
    A_TrayMenu.SetIcon("Open File Location", "C:\Windows\System32\shell32.dll", 4)
    A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowHotkeys(, , 4))
    A_TrayMenu.SetIcon("Show Hotkeys", "C:\Windows\System32\shell32.dll", 24)
    A_TrayMenu.Insert("E&xit")
    A_TrayMenu.Insert("E&xit", "Show/Hide", (*) => options.Toggle())
    A_TrayMenu.Default := "Show/Hide"
    A_TrayMenu.ClickCount := 1
}

BindingScript()

#HotIf (options.Checkbox[3].Value)
{
    +Space:: Send("_")
    XButton1:: Send("{F10}")
    XButton2:: Send("{F11}")
}
#HotIf

#Hotif (options.Checkbox[2].Value)
{
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
}
#HotIf

GetScriptStatus() {
    return overlay.isScriptEnabled
}

GetOption1() {
    return options.Checkbox[1].Value
}
GetOption4() {
    return options.Checkbox[4].Value
}
