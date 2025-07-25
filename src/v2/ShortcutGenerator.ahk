#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
;@Ahk2Exe-SetMainIcon C:\Users\jackb\Documents\AutoHotkey\icon\internet.ico

#Include <KeyBinding>
#Include <ShortcutTool>

ShortcutGenerator := ShortcutTool()
BindingScript()

A_TrayMenu.Delete()
A_TrayMenu.AddStandard()
if (A_IsCompiled) {
    A_TrayMenu.Insert("&Suspend Hotkeys", "&Reload Script", (*) => Reload())
    A_TrayMenu.Insert("&Suspend Hotkeys", "&Edit Script", (*) => Run("*edit " "C:\Users\jackb\Documents\AutoHotkey\src\v2\ShortcutGenerator.ahk"
    ))
    A_TrayMenu.Insert("&Suspend Hotkeys")
}
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Open File Location", (*) => Run("*open " "C:\Users\jackb\Documents\AutoHotkey\src\v2\"))
A_TrayMenu.SetIcon("Open File Location", "C:\Windows\System32\shell32.dll", 4)
A_TrayMenu.Insert("E&xit", "Show Hotkeys", (*) => ShowHotkeys())
A_TrayMenu.SetIcon("Show Hotkeys", "C:\Windows\System32\shell32.dll", 24)
A_TrayMenu.Insert("E&xit")
A_TrayMenu.Insert("E&xit", "Add ShortCut", (*) => ShortcutGenerator.AddShortcut())
A_TrayMenu.SetIcon("Add ShortCut", "C:\Windows\System32\shell32.dll", 44)
A_TrayMenu.Insert("E&xit", "Show/Hide", (*) => ShortcutGenerator.Toggle())
A_TrayMenu.Default := "Show/Hide"
A_TrayMenu.ClickCount := 1